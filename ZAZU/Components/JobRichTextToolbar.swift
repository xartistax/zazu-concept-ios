//
//  JobRichTextToolbar.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 15.10.2026.
//

import SwiftUI
import UIKit

import SwiftUI

struct JobRichTextToolbar: View {

    let editorState: JobRichTextEditorState

    var body: some View {
        HStack(spacing: ZAZUSpacing.medium) {

            Button {
                editorState.toggleBold()
            } label: {
                Image(systemName: "bold")
            }
            .accessibilityLabel("Fett")

            Button {
                editorState.toggleItalic()
            } label: {
                Image(systemName: "italic")
            }
            .accessibilityLabel("Kursiv")

            Button {
                editorState.toggleUnderline()
            } label: {
                Image(systemName: "underline")
            }
            .accessibilityLabel("Unterstrichen")
            
            Divider()
                .frame(height: 24)

            Menu {
                Button("Normaler Text") {
                    editorState.setHeading(level: 0)
                }

                Button("Überschrift 1") {
                    editorState.setHeading(level: 1)
                }

                Button("Überschrift 2") {
                    editorState.setHeading(level: 2)
                }
            } label: {
                Image(systemName: "textformat.size")
            }
            .accessibilityLabel("Textformat")

            Button {
                editorState.toggleBulletList()
            } label: {
                Image(systemName: "list.bullet")
            }
            .accessibilityLabel("Aufzählung")

            Spacer()
        }
        .buttonStyle(.bordered)
        .tint(ZAZUColors.primary)
    }
}
