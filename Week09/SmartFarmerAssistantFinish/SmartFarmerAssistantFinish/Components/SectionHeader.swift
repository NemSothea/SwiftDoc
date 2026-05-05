// Components/SectionHeader.swift
import SwiftUI

// MARK: - SectionHeader

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(.primary)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .foregroundColor(color)
                }
            }
        }
    }
}

// MARK: - LoadingRowView

struct LoadingRowView: View {
    @State private var pulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemGray4))
                .frame(width: 180, height: 14)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemGray5))
                .frame(width: 120, height: 12)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemGray5))
                .frame(width: 90, height: 10)
        }
        .padding(.vertical, 10)
        .opacity(pulse ? 1.0 : 0.4)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.9)
                .repeatForever(autoreverses: true)
            ) {
                pulse = true
            }
        }
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            if let buttonTitle, let action {
                PrimaryButton(title: buttonTitle, action: action)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        SectionHeader(
            title: "ប្រតិបត្តិការថ្មីៗ",
            icon: "dollarsign.circle.fill",
            color: .green,
            actionTitle: "មើលទាំងអស់",
            action: {}
        )
        .padding()

        SectionHeader(
            title: "សកម្មភាពខាងមុខ",
            icon: "calendar.badge.clock",
            color: .blue
        )
        .padding()

        Divider()

        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<3, id: \.self) { _ in
                LoadingRowView()
                    .padding(.horizontal)
                Divider()
            }
        }

        Divider()

        EmptyStateView(
            icon: "tray.fill",
            title: "មិនទាន់មានទិន្នន័យ",
            subtitle: "ចុចប៊ូតុងខាងក្រោម ដើម្បីបន្ថែម",
            buttonTitle: "បន្ថែមថ្មី",
            action: {}
        )
    }
    .background(Color(.systemGroupedBackground))
}
