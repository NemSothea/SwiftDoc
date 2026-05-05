// Reports/Views/SummaryCardView.swift
import SwiftUI

struct SummaryCardView: View {
    let report: MonthlyReport

    var body: some View {
        FarmCard(
            title: "សង្ខេបប្រចាំខែ",
            icon: "chart.pie.fill",
            iconColor: .orange
        ) {
            VStack(spacing: 0) {
                row(label: "ចំណូល",
                    value: report.income.formattedCurrency,
                    valueColor: .green,
                    icon: "arrow.up.circle.fill")
                Divider().padding(.horizontal, -16)
                row(label: "ចំណាយ",
                    value: report.expense.formattedCurrency,
                    valueColor: .red,
                    icon: "arrow.down.circle.fill")
                Divider().padding(.horizontal, -16)
                row(label: "ចំណេញ / ខាត",
                    value: report.profit.formattedCurrency,
                    valueColor: report.profit >= 0 ? .green : .red,
                    icon: report.profit >= 0
                        ? "checkmark.seal.fill"
                        : "exclamationmark.triangle.fill",
                    bold: true)
            }
        }
    }

    private func row(
        label: String,
        value: String,
        valueColor: Color,
        icon: String,
        bold: Bool = false
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(valueColor)
                .frame(width: 22)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(bold ? .bold : .regular)
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 10)
    }
}
