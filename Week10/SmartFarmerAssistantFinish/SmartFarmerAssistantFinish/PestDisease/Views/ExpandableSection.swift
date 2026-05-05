//
//  ExpandableSection.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI

/// A disclosure-style section header that toggles a chevron between
/// right (collapsed) and down (expanded). The open/closed state is held
/// locally with `@State` so each section expands independently — no
/// ViewModel or DisclosureGroup dependency (iOS 13+ compatible).
///
/// ```swift
/// ExpandableSection(title: "Symptoms", icon: "stethoscope") {
///     Text(pest.symptoms ?? "")
/// }
/// ```
struct ExpandableSection<Content: View>: View {
    let title: String
    var icon: String? = nil
    var initiallyExpanded: Bool = true
    @ViewBuilder let content: () -> Content

    @State private var isExpanded: Bool

    init(title: String,
         icon: String? = nil,
         initiallyExpanded: Bool = true,
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.initiallyExpanded = initiallyExpanded
        self.content = content
        _isExpanded = State(initialValue: initiallyExpanded)
    }

    /// Leading indent for the body so it aligns with where the header title
    /// starts (after the icon + 8pt spacing).
    private var bodyIndent: CGFloat { icon == nil ? 0 : 28 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon)
                            .foregroundColor(.green)
                            .frame(width: 20)
                    }
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical, 12)

            if isExpanded {
                content()
                    .padding(.leading, bodyIndent)
                    .padding(.bottom, 14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider()
        }
    }
}
