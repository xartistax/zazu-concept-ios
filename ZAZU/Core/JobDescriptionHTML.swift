//
//  JobDescriptionHTML.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 14.10.2026.
//

import Foundation
import UIKit

enum JobDescriptionHTML {

    // MARK: - HTML / Plain Text → NSAttributedString

    static func attributedString(from value: String) -> NSAttributedString {
        guard !value.isEmpty else {
            return NSAttributedString(string: "")
        }

        // Bestehende Klartextbeschreibungen unterstützen.
        guard containsSupportedHTML(value) else {
            return NSAttributedString(
                string: value,
                attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .body)
                ]
            )
        }

        let document = """
        <html>
        <head>
            <meta charset="utf-8">
        </head>
        <body>
            \(value)
        </body>
        </html>
        """

        guard let data = document.data(using: .utf8) else {
            return NSAttributedString(string: value)
        }

        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            return NSAttributedString(string: value)
        }
    }

    // MARK: - NSAttributedString → HTML

    static func html(from attributedString: NSAttributedString) -> String {
        let text = attributedString.string

        guard !text.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            return ""
        }

        let nsText = text as NSString
        var elements: [String] = []

        var location = 0

        while location < nsText.length {

            let paragraphRange = nsText.paragraphRange(
                for: NSRange(
                    location: location,
                    length: 0
                )
            )

            let paragraph = nsText
                .substring(with: paragraphRange)
                .trimmingCharacters(in: .newlines)

            guard !paragraph.isEmpty else {
                location = NSMaxRange(paragraphRange)
                continue
            }

            let contentRange = NSRange(
                location: paragraphRange.location,
                length: (paragraph as NSString).length
            )

            let content = inlineHTML(
                from: attributedString,
                range: contentRange
            )

            let font = attributedString.attribute(
                .font,
                at: paragraphRange.location,
                effectiveRange: nil
            ) as? UIFont

            let fontSize = font?.pointSize ?? 17

            if paragraph.hasPrefix("• ") {

                let bulletRange = NSRange(
                    location: paragraphRange.location + 2,
                    length: max(0, contentRange.length - 2)
                )

                let bulletContent = inlineHTML(
                    from: attributedString,
                    range: bulletRange
                )

                elements.append("<li>\(bulletContent)</li>")

            } else if fontSize >= 25 {

                elements.append("<h1>\(content)</h1>")

            } else if fontSize >= 20 {

                elements.append("<h2>\(content)</h2>")

            } else {

                elements.append("<p>\(content)</p>")
            }

            location = NSMaxRange(paragraphRange)
        }

        return wrapListItems(elements)
    }

    // MARK: - Inline Formatting

    private static func inlineHTML(
        from attributedString: NSAttributedString,
        range: NSRange
    ) -> String {
        guard range.length > 0 else {
            return ""
        }

        var result = ""

        attributedString.enumerateAttributes(
            in: range
        ) { attributes, subrange, _ in

            let rawText = (attributedString.string as NSString)
                .substring(with: subrange)

            var content = escapeHTML(rawText)

            // Fett und Kursiv
            if let font = attributes[.font] as? UIFont {

                let traits = font.fontDescriptor.symbolicTraits

                if traits.contains(.traitBold) {
                    content = "<strong>\(content)</strong>"
                }

                if traits.contains(.traitItalic) {
                    content = "<em>\(content)</em>"
                }
            }

            // Unterstrichen
            let underline = attributes[.underlineStyle] as? Int ?? 0

            if underline != 0 {
                content = "<u>\(content)</u>"
            }

            result += content
        }

        return result
    }

    // MARK: - Lists

    private static func wrapListItems(
        _ elements: [String]
    ) -> String {
        var result = ""
        var insideList = false

        for element in elements {

            let isListItem = element.hasPrefix("<li>")

            if isListItem && !insideList {
                result += "<ul>"
                insideList = true
            }

            if !isListItem && insideList {
                result += "</ul>"
                insideList = false
            }

            result += element
        }

        if insideList {
            result += "</ul>"
        }

        return result
    }

    // MARK: - HTML Escaping

    private static func escapeHTML(
        _ text: String
    ) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    // MARK: - HTML Detection

    private static func containsSupportedHTML(
        _ value: String
    ) -> Bool {
        let pattern =
            #"</?(?:p|h1|h2|strong|em|u|ul|li)(?:\s[^>]*)?>"#

        return value.range(
            of: pattern,
            options: [
                .regularExpression,
                .caseInsensitive
            ]
        ) != nil
    }
}
