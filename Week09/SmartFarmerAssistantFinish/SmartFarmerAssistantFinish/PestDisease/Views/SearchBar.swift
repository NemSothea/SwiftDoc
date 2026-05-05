//
//  SearchBar.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI

/// iOS 13+ custom search bar. Replaces `.searchable(...)` (iOS 15+) so the
/// module stays compatible with the course's minimum deployment target.
///
/// - Shows a magnifying-glass icon and a clear (×) button when text is present
/// - A "Cancel" button appears while the field is focused and resets the text
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "ស្វែងរក…"

    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing = editing
                    }
                })
                .autocapitalization(.none)
                .disableAutocorrection(true)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if isEditing {
                Button("បោះបង់") {
                    text = ""
                    isEditing = false
                    hideKeyboard()
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
