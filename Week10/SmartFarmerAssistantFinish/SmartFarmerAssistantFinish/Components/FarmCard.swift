// Components/FarmCard.swift
import SwiftUI

struct FarmCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()
                .padding(.horizontal, 16)

            content()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .farmCard()
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            FarmCard(title: "ចំណូល / ចំណាយ", icon: "dollarsign.circle.fill", iconColor: .green) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ចំណូល")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$1,200")
                            .bold()
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("ចំណាយ")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$850")
                            .bold()
                            .foregroundColor(.red)
                    }
                }
            }

            FarmCard(title: "សកម្មភាពខាងមុខ", icon: "calendar.badge.clock", iconColor: .blue) {
                Text("ស្រោចទឹកចំការ")
                    .foregroundColor(.primary)
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
