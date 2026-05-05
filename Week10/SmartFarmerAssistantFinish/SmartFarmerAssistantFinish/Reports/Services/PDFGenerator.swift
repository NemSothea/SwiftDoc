// Reports/Services/PDFGenerator.swift
import UIKit

struct PDFGenerator {

    static let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)  // A4 at 72 dpi

    // MARK: - Public entry point

    static func makeReportPDF(
        title: String,
        subtitle: String,
        rows: [(String, String)],
        reports: [MonthlyReport]
    ) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { ctx in
            ctx.beginPage()
            var cursorY: CGFloat = 40
            cursorY = drawTitle(title, subtitle: subtitle, y: cursorY)
            cursorY = drawDivider(y: cursorY + 12)
            cursorY = drawTable(rows, y: cursorY + 16)
            cursorY = drawDivider(y: cursorY + 16)
            if !reports.isEmpty {
                drawBarChart(reports, y: cursorY + 20)
            }
            drawFooter()
        }
    }

    // MARK: - Write to temp file

    static func writeTempFile(_ data: Data, named filename: String) -> URL? {
        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(filename + ".pdf")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Title block

    @discardableResult
    private static func drawTitle(_ title: String, subtitle: String, y: CGFloat) -> CGFloat {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font:            UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font:            UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.gray
        ]
        title.draw(at: CGPoint(x: 40, y: y),      withAttributes: titleAttrs)
        subtitle.draw(at: CGPoint(x: 40, y: y + 30), withAttributes: subAttrs)
        return y + 56
    }

    // MARK: - Horizontal divider

    @discardableResult
    private static func drawDivider(y: CGFloat) -> CGFloat {
        guard let ctx = UIGraphicsGetCurrentContext() else { return y }
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.setLineWidth(0.5)
        ctx.move(to: CGPoint(x: 40, y: y))
        ctx.addLine(to: CGPoint(x: pageRect.width - 40, y: y))
        ctx.strokePath()
        return y
    }

    // MARK: - Two-column summary table

    @discardableResult
    private static func drawTable(_ rows: [(String, String)], y: CGFloat) -> CGFloat {
        let rowH: CGFloat = 28
        var cursorY = y
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font:            UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.darkGray
        ]

        for (i, (label, value)) in rows.enumerated() {
            if i % 2 == 0, let ctx = UIGraphicsGetCurrentContext() {
                ctx.setFillColor(UIColor.systemGray6.cgColor)
                ctx.fill(CGRect(x: 40, y: cursorY - 4,
                                width: pageRect.width - 80, height: rowH))
            }

            let isProfitRow = label.contains("ចំណេញ")
            let rawProfit   = rows.last?.1 ?? ""
            let isNegative  = isProfitRow && rawProfit.hasPrefix("-")
            let valueColor: UIColor = isProfitRow
                ? (isNegative ? .systemRed : .systemGreen)
                : .black
            let valueAttrs: [NSAttributedString.Key: Any] = [
                .font:            UIFont.boldSystemFont(ofSize: 13),
                .foregroundColor: valueColor
            ]

            label.draw(at: CGPoint(x: 50, y: cursorY),  withAttributes: labelAttrs)
            value.draw(at: CGPoint(x: 320, y: cursorY), withAttributes: valueAttrs)
            cursorY += rowH
        }
        return cursorY
    }

    // MARK: - Mini bar chart

    private static func drawBarChart(_ reports: [MonthlyReport], y: CGFloat) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let maxValue = reports.flatMap { [$0.income, $0.expense] }.max() ?? 1
        let chartH:  CGFloat = 150
        let chartW            = pageRect.width - 80
        let slotW             = chartW / CGFloat(reports.count)
        let barW:    CGFloat  = slotW * 0.28

        // Chart title
        let chartTitleAttrs: [NSAttributedString.Key: Any] = [
            .font:            UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        "Monthly Income vs Expense".draw(
            at: CGPoint(x: 40, y: y), withAttributes: chartTitleAttrs)

        let baseline = y + 20 + chartH

        for (i, entry) in reports.enumerated() {
            let slotX = 40 + CGFloat(i) * slotW

            // Income bar (green)
            let incomeH = CGFloat(entry.income / maxValue) * chartH
            ctx.setFillColor(UIColor.systemGreen.cgColor)
            ctx.fill(CGRect(x: slotX + 4,
                            y: baseline - incomeH,
                            width: barW, height: incomeH))

            // Expense bar (red)
            let expenseH = CGFloat(entry.expense / maxValue) * chartH
            ctx.setFillColor(UIColor.systemRed.withAlphaComponent(0.75).cgColor)
            ctx.fill(CGRect(x: slotX + 4 + barW + 2,
                            y: baseline - expenseH,
                            width: barW, height: expenseH))

            // Month label
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font:            UIFont.systemFont(ofSize: 8),
                .foregroundColor: UIColor.gray
            ]
            entry.monthLabel.draw(
                at: CGPoint(x: slotX + 4, y: baseline + 4),
                withAttributes: labelAttrs)
        }

        // Baseline rule
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.setLineWidth(0.5)
        ctx.move(to:    CGPoint(x: 40, y: baseline))
        ctx.addLine(to: CGPoint(x: pageRect.width - 40, y: baseline))
        ctx.strokePath()

        // Legend
        let legendY = baseline + 22
        ctx.setFillColor(UIColor.systemGreen.cgColor)
        ctx.fill(CGRect(x: 40, y: legendY, width: 10, height: 10))
        let legendAttrs: [NSAttributedString.Key: Any] = [
            .font:            UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.darkGray
        ]
        "Income".draw(at: CGPoint(x: 56, y: legendY - 1), withAttributes: legendAttrs)

        ctx.setFillColor(UIColor.systemRed.withAlphaComponent(0.75).cgColor)
        ctx.fill(CGRect(x: 110, y: legendY, width: 10, height: 10))
        "Expense".draw(at: CGPoint(x: 126, y: legendY - 1), withAttributes: legendAttrs)
    }

    // MARK: - Footer

    private static func drawFooter() {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        let text = "Generated by SmartFarmerAssistant · \(df.string(from: Date()))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font:            UIFont.italicSystemFont(ofSize: 9),
            .foregroundColor: UIColor.lightGray
        ]
        text.draw(at: CGPoint(x: 40, y: pageRect.height - 30),
                  withAttributes: attrs)
    }
}
