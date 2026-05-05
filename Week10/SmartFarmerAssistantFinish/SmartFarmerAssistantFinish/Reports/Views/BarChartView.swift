// Reports/Views/BarChartView.swift
import SwiftUI

struct BarChartView: View {
    let entries: [MonthlyReport]

    private var maxValue: Double {
        entries.flatMap { [$0.income, $0.expense] }.max() ?? 1
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let totalW  = geo.size.width
                let slotW   = totalW / CGFloat(max(1, entries.count))
                let barW    = slotW * 0.30
                let barGap  = slotW * 0.06

                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(entries) { entry in
                        VStack(spacing: 3) {
                            HStack(alignment: .bottom, spacing: barGap) {
                                BarShape(
                                    heightFraction: CGFloat(entry.income / maxValue)
                                )
                                .fill(Color.green)
                                .frame(width: barW)
                                .animation(
                                    .easeOut(duration: 0.5),
                                    value: entry.income
                                )

                                BarShape(
                                    heightFraction: CGFloat(entry.expense / maxValue)
                                )
                                .fill(Color.red.opacity(0.8))
                                .frame(width: barW)
                                .animation(
                                    .easeOut(duration: 0.5),
                                    value: entry.expense
                                )
                            }
                            .frame(height: geo.size.height - 22)

                            Text(entry.monthLabel)
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                                .frame(width: slotW)
                        }
                        .frame(width: slotW)
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                legendItem(color: .green,            label: "ចំណូល")
                legendItem(color: .red.opacity(0.8), label: "ចំណាយ")
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
