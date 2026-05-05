// Reports/Views/MonthPickerView.swift
import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedMonth: Date
    let canGoNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    private var label: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df.string(from: selectedMonth)
    }

    var body: some View {
        HStack(spacing: 20) {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }

            Text(label)
                .font(.headline)
                .frame(minWidth: 160)

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(canGoNext ? .primary : Color(.systemGray4))
            }
            .disabled(!canGoNext)
        }
        .padding(.vertical, 10)
    }
}
