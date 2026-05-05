// Components/PrimaryButton.swift
import SwiftUI

// MARK: - PrimaryButton

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var color: Color = .green
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(color)
            .cornerRadius(14)
        }
        .scalePress()
        .accessibilityLabel(title)
    }
}

// MARK: - SecondaryButton

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var color: Color = .green
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color, lineWidth: 1.5)
            )
            .cornerRadius(14)
        }
        .scalePress()
        .accessibilityLabel(title)
    }
}

// MARK: - IconActionButton

struct IconActionButton: View {
    let icon: String
    var color: Color = .green
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .cornerRadius(22)
        }
        .scalePress()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "បន្ថែមប្រតិបត្តិការ", icon: "plus.circle.fill", color: .green) {}
        PrimaryButton(title: "រក្សាទុក", color: .blue) {}
        SecondaryButton(title: "បោះបង់", icon: "xmark.circle", color: .red) {}
        SecondaryButton(title: "ត្រឡប់ក្រោយ", color: .gray) {}
        HStack(spacing: 16) {
            IconActionButton(icon: "plus", color: .green) {}
            IconActionButton(icon: "pencil", color: .blue) {}
            IconActionButton(icon: "trash", color: .red) {}
        }
    }
    .padding()
}
