//
//  ZAZUDropdownField.swift
//  ZAZU
//
//  Created by Demian on 30.10.2026.
//


import SwiftUI

struct ZAZUDropdownField<SelectionValue: Hashable, Content: View>: View {

    let title: String
    @Binding var selection: SelectionValue
    @ViewBuilder let content: Content

    init(
        _ title: String,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._selection = selection
        self.content = content()
    }

    var body: some View {
        Picker(title, selection: $selection) {
            content
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .tint(ZAZUColors.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, ZAZUSpacing.medium)
        .frame(minHeight: 50)
        .background(ZAZUColors.veryLightPurple)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
    }
}

