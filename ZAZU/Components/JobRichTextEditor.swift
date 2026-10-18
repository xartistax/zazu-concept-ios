//
//  JobRichTextEditor.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 15.10.2026.
//

import SwiftUI
import UIKit


@MainActor
@Observable
final class JobRichTextEditorState {

    weak var textView: UITextView?

    var revision = 0
    var onTextChange: ((NSAttributedString) -> Void)?

    func toggleBold() {
        toggleFontTrait(.traitBold)
    }

    func toggleItalic() {
        toggleFontTrait(.traitItalic)
    }

    func toggleUnderline() {
        guard let textView else { return }

        let range = textView.selectedRange

        guard range.length > 0 else { return }

        let text = NSMutableAttributedString(
            attributedString: textView.attributedText
        )

        let current = text.attribute(
            .underlineStyle,
            at: range.location,
            effectiveRange: nil
        ) as? Int ?? 0

        let newValue = current == NSUnderlineStyle.single.rawValue
            ? 0
            : NSUnderlineStyle.single.rawValue

        text.addAttribute(
            .underlineStyle,
            value: newValue,
            range: range
        )

        apply(text, selection: range)
    }

    private func toggleFontTrait(
        _ trait: UIFontDescriptor.SymbolicTraits
    ) {
        guard let textView else { return }

        let range = textView.selectedRange

        guard range.length > 0 else { return }

        let text = NSMutableAttributedString(
            attributedString: textView.attributedText
        )

        let currentFont = text.attribute(
            .font,
            at: range.location,
            effectiveRange: nil
        ) as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)

        let shouldEnable = !currentFont.fontDescriptor.symbolicTraits
            .contains(trait)

        text.enumerateAttribute(
            .font,
            in: range
        ) { value, subrange, _ in

            let font = value as? UIFont
                ?? UIFont.preferredFont(forTextStyle: .body)

            var traits = font.fontDescriptor.symbolicTraits

            if shouldEnable {
                traits.insert(trait)
            } else {
                traits.remove(trait)
            }

            guard let descriptor = font.fontDescriptor
                .withSymbolicTraits(traits) else {
                return
            }

            text.addAttribute(
                .font,
                value: UIFont(
                    descriptor: descriptor,
                    size: font.pointSize
                ),
                range: subrange
            )
        }

        apply(text, selection: range)
    }

    private func apply(
        _ text: NSAttributedString,
        selection: NSRange
    ) {
        guard let textView else { return }

        textView.attributedText = text
        textView.selectedRange = selection

        revision += 1
        onTextChange?(text)
    }
    
    
    // MARK: - Paragraph Formatting

    func setHeading(level: Int) {
        guard let textView else { return }

        let selection = textView.selectedRange
        let text = NSMutableAttributedString(
            attributedString: textView.attributedText
        )

        guard text.length > 0 else { return }

        let paragraphRange = (text.string as NSString)
            .paragraphRange(for: selection)

        let fontSize: CGFloat

        switch level {
        case 1:
            fontSize = 26
        case 2:
            fontSize = 21
        default:
            fontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
        }

        let font: UIFont = level == 0
            ? .preferredFont(forTextStyle: .body)
            : .boldSystemFont(ofSize: fontSize)

        text.addAttribute(
            .font,
            value: font,
            range: paragraphRange
        )

        apply(text, selection: selection)
    }

    func toggleBulletList() {
        guard let textView else { return }

        let selection = textView.selectedRange
        let text = NSMutableAttributedString(
            attributedString: textView.attributedText
        )

        let nsText = text.string as NSString
        
        guard selection.location <= nsText.length else {
            return
        }
        
        let paragraphRange = nsText.paragraphRange(for: selection)

        let paragraph = nsText.substring(with: paragraphRange)

        if paragraph.hasPrefix("• ") {
            text.replaceCharacters(
                in: NSRange(location: paragraphRange.location, length: 2),
                with: ""
            )
        } else {
            text.insert(
                NSAttributedString(string: "• "),
                at: paragraphRange.location
            )
        }

        let newLocation = min(
            text.length,
            selection.location + (paragraph.hasPrefix("• ") ? -2 : 2)
        )

        apply(
            text,
            selection: NSRange(location: max(0, newLocation), length: 0)
        )
    }
}

struct JobRichTextEditor: UIViewRepresentable {

    @Binding var attributedText: NSAttributedString

    let editorState: JobRichTextEditorState
    
    

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.attributedText = attributedText

        editorState.textView = textView
        
        editorState.onTextChange = { [weak textView] updatedText in

            guard textView != nil else { return }

            context.coordinator.parent.attributedText = updatedText

        }

        return textView
    }
    
    

    func updateUIView(
        _ textView: UITextView,
        context: Context
    ) {
        guard !textView.attributedText.isEqual(to: attributedText) else {
            return
        }

        let selectedRange = textView.selectedRange

        textView.attributedText = attributedText

        if selectedRange.location + selectedRange.length
            <= textView.attributedText.length {
            textView.selectedRange = selectedRange
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {

        var parent: JobRichTextEditor

        init(_ parent: JobRichTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }
    }
    
}
