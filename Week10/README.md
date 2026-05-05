# Week 10 — Data Export & Reports

**Project:** SmartFarmerAssistant  
**Branch:** advancedoc  
**Topic:** Generating Useful Reports for Farmers

---

## Learning Objectives

By the end of this week, students will be able to:

- Build a custom bar chart using `GeometryReader` and `Shape` — no `Swift Charts` dependency (iOS 13+)
- Generate monthly profit/loss reports by grouping Core Data transactions by calendar month
- Export report data as a CSV file using `FileManager.temporaryDirectory`
- Generate a PDF with `UIGraphicsPDFRenderer` — text, tables, and custom drawing (iOS 10+)
- Implement `UIActivityViewController` wrapped in `UIViewControllerRepresentable` to share files (iOS 13+)
- Wire the full flow: Generate → Preview → Share in a single `ReportTabView`

---

## ⚠️ iOS 13+ API Rules (Quick Reference)

| Feature | ❌ iOS 16+ Only | ✅ iOS 13+ Correct |
|---|---|---|
| Bar Charts | `Swift Charts` | `GeometryReader` + `BarShape: Shape` |
| Share sheet | `ShareLink` | `UIActivityViewController` wrapped with `UIViewControllerRepresentable` |
| PDF from SwiftUI view | `ImageRenderer` | `UIGraphicsPDFRenderer` + `NSString.draw(at:)` |
| Date grouping | Careless `dateComponents` | `Calendar.dateInterval(of: .month, for:)` |
| Navigation | `NavigationStack` | `NavigationView` (existing convention) |

> This course keeps the deployment target at iOS 13. Every technique this week runs on iOS 13 and later.

---

## Lesson Breakdown

| Lesson | Topic |
|--------|-------|
| 10.1 | `MonthlyReport` model + `ReportViewModel` — grouping transactions by month |
| 10.2 | `BarShape` + `BarChartView` — custom bar chart with `GeometryReader` |
| 10.3 | `CSVExporter` — generating a CSV string and writing it to a temp file |
| 10.4 | `PDFGenerator` — building a PDF report with `UIGraphicsPDFRenderer` |
| 10.5 | `ShareSheet` + `UIActivityViewController` — sharing files from SwiftUI |

---

## 🗂 Folder Structure

```
SmartFarmerAssistantFinish/
└── Reports/
    ├── Models/
    │   └── MonthlyReport.swift            ← income, expense, profit, monthLabel
    ├── ViewModels/
    │   └── ReportViewModel.swift          ← buildMonthlyReports(), summaryRows
    ├── Services/
    │   ├── CSVExporter.swift              ← makeTransactionCSV(), writeToTempFile()
    │   └── PDFGenerator.swift            ← makeReportPDF(), drawTitle(), drawTable()
    └── Views/
        ├── ReportTabView.swift            ← root: chart + summary + export buttons
        ├── BarChartView.swift             ← GeometryReader + ForEach of BarShape
        ├── BarShape.swift                 ← Shape protocol implementation
        ├── SummaryCardView.swift         ← income / expense / profit card
        └── MonthPickerView.swift         ← simple month navigation arrows
Shared/
    └── ShareSheet.swift                  ← UIViewControllerRepresentable wrapper
```

| Layer | Responsibility |
|---|---|
| **Models** | Plain Swift struct — `MonthlyReport` is not a Core Data entity |
| **ViewModels** | Grouping, filtering, and formatting — pure functions, easy to test |
| **Services** | Side-effect helpers that produce `String` (CSV) or `Data` (PDF) |
| **Views** | SwiftUI only — no file I/O or Core Data writes |
| **Shared** | `ShareSheet` is reused by Finance and Dashboard in later milestones |

---

## 🏛 Architecture

```
┌──────────────────────── App launch ─────────────────────────────────┐
│  MainTabView                                                        │
│      Tab 5 → ReportTabView   ← NEW this week                        │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────── User opens Report tab ────────────────────────────────┐
│  ReportTabView                                                      │
│      ├─ @FetchRequest<Transaction>   (date, descending)             │
│      ├─ @StateObject vm = ReportViewModel()                         │
│      ├─ MonthPickerView($vm.selectedMonth, canGoNext, prev, next)   │
│      ├─ FarmCard { BarChartView(entries: monthlyReports.suffix(6)) }│
│      │          └─ emptyChartPlaceholder if no transactions          │
│      ├─ SummaryCardView(report: vm.selectedReport(from:))           │
│      └─ exportButtons:                                              │
│             SectionHeader("នាំចេញទិន្នន័យ")                         │
│             PrimaryButton("CSV") → DispatchQueue.global             │
│                 └─► CSVExporter → writeToTempFile → ShareSheet      │
│             PrimaryButton("PDF") → DispatchQueue.global             │
│                 └─► PDFGenerator → writeTempFile → ShareSheet       │
│      .loadingOverlay(isLoading: isExporting)                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📚 Lesson 10.1 — MonthlyReport Model & ReportViewModel (30 minutes)

**Goal:** define a plain-Swift value type that holds one month of aggregated data, and a view model that builds the list from Core Data transactions.

### MonthlyReport

```swift
// Reports/Models/MonthlyReport.swift
struct MonthlyReport: Identifiable {
    let id      = UUID()
    let month:   Date
    let income:  Double
    let expense: Double

    var profit: Double { income - expense }

    var monthLabel: String {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df.string(from: month)
    }

    var monthYearLabel: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df.string(from: month)
    }
}
```

> `monthLabel` (e.g. "May") labels each bar on the chart. `monthYearLabel` (e.g. "May 2026") is
> used as the PDF subtitle so the report is unambiguously dated.

> **Why not Core Data?** `MonthlyReport` is a **computed view** of `Transaction` rows — it's
> always derived and never stored. Storing it in Core Data would duplicate data and create
> a sync problem. Keep it in Swift; rebuild it whenever transactions change.

### ReportViewModel

```swift
// Reports/ViewModels/ReportViewModel.swift
class ReportViewModel: ObservableObject {

    // Initialise to the canonical start of the current calendar month,
    // not just Date() — avoids subtle grouping mismatches near month boundaries.
    @Published var selectedMonth: Date = {
        Calendar.current.dateInterval(of: .month, for: Date())!.start
    }()

    // MARK: - Grouping

    func buildMonthlyReports(_ transactions: [Transaction]) -> [MonthlyReport] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: transactions) { txn -> Date in
            cal.dateInterval(of: .month, for: txn.date ?? Date())!.start
        }
        return grouped
            .map { monthStart, txns in
                MonthlyReport(
                    month:   monthStart,
                    income:  txns.filter { $0.isIncome }.map(\.amount).reduce(0, +),
                    expense: txns.filter { $0.isExpense }.map(\.amount).reduce(0, +)
                )
            }
            .sorted { $0.month < $1.month }
    }

    func selectedReport(from reports: [MonthlyReport]) -> MonthlyReport {
        reports.first {
            Calendar.current.isDate($0.month, equalTo: selectedMonth, toGranularity: .month)
        } ?? MonthlyReport(month: selectedMonth, income: 0, expense: 0)
    }

    // MARK: - Month navigation

    func goToPreviousMonth() {
        selectedMonth = Calendar.current
            .date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }

    func goToNextMonth() {
        selectedMonth = Calendar.current
            .date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }

    var canGoToNextMonth: Bool {
        let next = Calendar.current
            .date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
        return next <= Date()
    }

    // MARK: - PDF helpers

    // Uses Double.formattedCurrency from Utilities/Formatters.swift
    func summaryRows(from report: MonthlyReport) -> [(String, String)] {
        [
            ("ចំណូលសរុប:",    report.income.formattedCurrency),
            ("ចំណាយសរុប:",  report.expense.formattedCurrency),
            ("ចំណេញ / ខាត:", report.profit.formattedCurrency),
        ]
    }

    func transactions(for month: Date, from all: [Transaction]) -> [Transaction] {
        all.filter {
            guard let d = $0.date else { return false }
            return Calendar.current.isDate(d, equalTo: month, toGranularity: .month)
        }
    }
}
```

| Design choice | Why |
|---|---|
| `dateInterval(of: .month, for:).start` for init | Canonical month start prevents off-by-one when `Date()` is near a boundary |
| `$0.isExpense` not `!$0.isIncome` | `Transaction` has both computed properties — using the explicit one is clearer |
| `selectedReport(from:)` returns a zero report | The chart and summary never crash on an empty month — zero bars render, $0.00 displays |
| `canGoToNextMonth` guard | Prevents navigating into the future, where no data will ever exist |
| `summaryRows` reuses `formattedCurrency` | One currency formatter defined in `Formatters.swift` — no duplication |

---

## 📚 Lesson 10.2 — Custom Bar Chart with GeometryReader + Shape (60 minutes)

**Goal:** draw an income/expense paired bar chart that adapts to any screen width — no `Swift Charts` required.

### BarShape

```swift
// Reports/Views/BarShape.swift
import SwiftUI

struct BarShape: Shape {
    var heightFraction: CGFloat   // 0.0 … 1.0

    // animatableData makes the bar grow with withAnimation {}
    var animatableData: CGFloat {
        get { heightFraction }
        set { heightFraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let barH = rect.height * max(0, min(1, heightFraction))
        p.addRect(CGRect(
            x:      0,
            y:      rect.height - barH,
            width:  rect.width,
            height: barH
        ))
        return p
    }
}
```

> **Why bottom-anchored?** Bar charts grow upward — `y: rect.height - barH` starts from the
> baseline and fills toward the top, which matches both user intuition and standard chart
> conventions.

> **Why `animatableData`?** Adding `animatableData` lets SwiftUI interpolate `heightFraction`
> between values. Wrap an update in `withAnimation(.easeOut(duration: 0.5))` and the bar grows
> smoothly — zero extra code in the view.

### BarChartView

```swift
// Reports/Views/BarChartView.swift
struct BarChartView: View {
    let entries: [MonthlyReport]

    private var maxValue: Double {
        entries.flatMap { [$0.income, $0.expense] }.max() ?? 1
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let totalW = geo.size.width
                let slotW  = totalW / CGFloat(max(1, entries.count))
                let barW   = slotW * 0.30
                let barGap = slotW * 0.06

                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(entries) { entry in
                        VStack(spacing: 3) {
                            HStack(alignment: .bottom, spacing: barGap) {
                                BarShape(heightFraction: CGFloat(entry.income / maxValue))
                                    .fill(Color.green)
                                    .frame(width: barW)
                                    .animation(.easeOut(duration: 0.5), value: entry.income)

                                BarShape(heightFraction: CGFloat(entry.expense / maxValue))
                                    .fill(Color.red.opacity(0.8))
                                    .frame(width: barW)
                                    .animation(.easeOut(duration: 0.5), value: entry.expense)
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

            // Legend — lives inside the same VStack so it's always visible
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
            Text(label).font(.caption).foregroundColor(.secondary)
        }
    }
}
```

**Caller (`ReportTabView`) passes only the last 6 months:**

```swift
BarChartView(entries: Array(monthlyReports.suffix(6)))
    .frame(height: 200)
```

> Limiting to 6 keeps the bars wide enough to read on an iPhone SE. The full history is
> available in the CSV/PDF export.

| Design choice | Why |
|---|---|
| `GeometryReader` for widths | One formula works on iPhone SE and iPad Pro — no hardcoded pixel values |
| `maxValue` includes both income and expense | Both bars share the same scale — a $500 income bar and a $500 expense bar have identical heights |
| `.animation(value:)` on each bar | The bar grows when `entries` changes — the `animatableData` conformance does the interpolation |
| Paired bars side by side | Farmers instantly see whether income exceeded expenses in each month — no mental math |

---

## 📚 Lesson 10.3 — CSV Export (30 minutes)

**Goal:** convert `[Transaction]` into a comma-separated string, write it to a temp file, and return the `URL` for sharing.

```swift
// Reports/Services/CSVExporter.swift
struct CSVExporter {

    static func makeTransactionCSV(
        _ transactions: [Transaction]
    ) -> String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none

        var lines = ["Date,Type,Category,Amount,Note"]
        for t in transactions {
            let date     = df.string(from: t.date ?? Date())
            let type_    = t.isIncome ? "Income" : "Expense"
            let category = escape(t.category)
            let amount   = String(format: "%.2f", t.amount)
            let note     = escape(t.note)
            lines.append("\(date),\(type_),\(category),\(amount),\(note)")
        }
        return lines.joined(separator: "\n")
    }

    /// Write to a temp file and return the URL — nil if the write fails.
    static func writeToTempFile(
        _ csv: String,
        named filename: String
    ) -> URL? {
        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(filename + ".csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    // RFC 4180 escaping: wrap in quotes if the value contains commas,
    // double-quotes, or newlines — all three can break column alignment.
    private static func escape(_ value: String?) -> String {
        guard let v = value, !v.isEmpty else { return "" }
        if v.contains(",") || v.contains("\"") || v.contains("\n") {
            return "\"\(v.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return v
    }
}
```

**Usage in the view (background thread):**

```swift
private func exportCSV() {
    isExporting = true
    DispatchQueue.global(qos: .userInitiated).async {
        let csv = CSVExporter.makeTransactionCSV(allTransactions)
        let url = CSVExporter.writeToTempFile(csv, named: "farm_report")
        DispatchQueue.main.async {
            isExporting = false
            if let url = url { shareItems = [url]; showShare = true }
        }
    }
}
```

| Design choice | Why |
|---|---|
| `.temporaryDirectory` | No entitlement required — the OS cleans it up automatically |
| `atomically: true` | If the app crashes mid-write, the previous file is unchanged rather than corrupted |
| Quote fields containing commas | Standard RFC 4180 CSV escaping — Excel and Google Sheets both parse it correctly |
| `DateFormatter` with `dateStyle: .short` | Produces a locale-appropriate date string without hard-coded separators |

---

## 📚 Lesson 10.4 — PDF Generator with PDFKit (60 minutes)

**Goal:** use `UIGraphicsPDFRenderer` to draw a formatted one-page report: title, date, summary table, and a simple bar chart drawn in Core Graphics.

```swift
// Reports/Services/PDFGenerator.swift
import UIKit

struct PDFGenerator {

    static let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)  // A4 at 72 dpi

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

    // ── Title block ────────────────────────────────────────────────────
    @discardableResult
    private static func drawTitle(
        _ title: String, subtitle: String, y: CGFloat
    ) -> CGFloat {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font:            UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font:            UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.gray
        ]
        title.draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttrs)
        subtitle.draw(at: CGPoint(x: 40, y: y + 30), withAttributes: subAttrs)
        return y + 56
    }

    // ── Horizontal divider ─────────────────────────────────────────────
    @discardableResult
    private static func drawDivider(y: CGFloat) -> CGFloat {
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.setLineWidth(0.5)
        ctx.move(to: CGPoint(x: 40, y: y))
        ctx.addLine(to: CGPoint(x: pageRect.width - 40, y: y))
        ctx.strokePath()
        return y
    }

    // ── Two-column summary table ───────────────────────────────────────
    @discardableResult
    private static func drawTable(
        _ rows: [(String, String)], y: CGFloat
    ) -> CGFloat {
        let rowH: CGFloat = 26
        var cursorY = y
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.darkGray
        ]

        for (i, (label, value)) in rows.enumerated() {
            // Alternating row background
            if i % 2 == 0 {
                let ctx = UIGraphicsGetCurrentContext()!
                ctx.setFillColor(UIColor.systemGray6.cgColor)
                ctx.fill(CGRect(x: 40, y: cursorY - 4,
                                width: pageRect.width - 80, height: rowH))
            }

            let valueColor: UIColor = label.contains("ចំណេញ")
                ? .systemGreen : .black
            let valueAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 13),
                .foregroundColor: valueColor
            ]

            label.draw(at: CGPoint(x: 50, y: cursorY),  withAttributes: labelAttrs)
            value.draw(at: CGPoint(x: 320, y: cursorY), withAttributes: valueAttrs)
            cursorY += rowH
        }
        return cursorY
    }

    // ── Mini bar chart in the PDF ──────────────────────────────────────
    private static func drawBarChart(
        _ reports: [MonthlyReport], y: CGFloat, maxY: CGFloat
    ) {
        guard !reports.isEmpty else { return }
        let ctx       = UIGraphicsGetCurrentContext()!
        let maxValue  = reports.flatMap { [$0.income, $0.expense] }.max() ?? 1
        let chartH: CGFloat = min(160, maxY - y)
        let chartW    = pageRect.width - 80
        let slotW     = chartW / CGFloat(reports.count)
        let barW      = slotW * 0.28

        // Chart title
        let chartTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        "Monthly Income vs Expense".draw(
            at: CGPoint(x: 40, y: y), withAttributes: chartTitleAttrs)

        let baseline = y + 20 + chartH
        for (i, entry) in reports.enumerated() {
            let slotX = 40 + CGFloat(i) * slotW

            // Income bar
            let incomeH = CGFloat(entry.income / maxValue) * chartH
            ctx.setFillColor(UIColor.systemGreen.cgColor)
            ctx.fill(CGRect(x: slotX + 4,
                            y: baseline - incomeH,
                            width: barW, height: incomeH))

            // Expense bar
            let expenseH = CGFloat(entry.expense / maxValue) * chartH
            ctx.setFillColor(UIColor.systemRed.withAlphaComponent(0.75).cgColor)
            ctx.fill(CGRect(x: slotX + 4 + barW + 2,
                            y: baseline - expenseH,
                            width: barW, height: expenseH))

            // Month label
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8),
                .foregroundColor: UIColor.gray
            ]
            entry.monthLabel.draw(
                at: CGPoint(x: slotX + 4, y: baseline + 4),
                withAttributes: labelAttrs)
        }
    }

    // ── Footer ─────────────────────────────────────────────────────────
    private static func drawFooter() {
        let df = DateFormatter()
        df.dateStyle = .long
        let text = "Generated by SmartFarmerAssistant · \(df.string(from: Date()))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 9),
            .foregroundColor: UIColor.lightGray
        ]
        text.draw(at: CGPoint(x: 40, y: pageRect.height - 30),
                  withAttributes: attrs)
    }
}
```

| Design choice | Why |
|---|---|
| `UIGraphicsPDFRenderer` | Available from iOS 10+ — no `PDFKit` import needed for generation |
| `@discardableResult` on draw helpers | Each helper returns the next `cursorY` — callers can chain them or ignore the value |
| Alternating row background | Improves readability in the printed table — same convention as any spreadsheet |
| `drawBarChart` inside the same PDF context | Draws natively at PDF vector resolution — no pixel-blur when zoomed or printed |
| Footer with generation date | Farmers often compare multiple exports — the date tells them which one is newest |

---

## 📚 Lesson 10.5 — UIActivityViewController & ShareSheet (30 minutes)

**Goal:** expose iOS's system share sheet from SwiftUI on iOS 13 — no `ShareLink`.

### ShareSheet wrapper

```swift
// Shared/ShareSheet.swift
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        let avc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return avc
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
```

### ReportTabView — full export flow

The view holds three pieces of state and wires them together:

```swift
// Reports/Views/ReportTabView.swift
@State private var showShare   = false
@State private var shareItems: [Any] = []
@State private var isExporting = false

// Export actions run on a background thread so the UI stays responsive
private func exportCSV() {
    isExporting = true
    DispatchQueue.global(qos: .userInitiated).async {
        let csv = CSVExporter.makeTransactionCSV(allTransactions)
        let url = CSVExporter.writeToTempFile(csv, named: "farm_report")
        DispatchQueue.main.async {
            isExporting = false
            if let url = url { shareItems = [url]; showShare = true }
        }
    }
}

private func exportPDF() {
    isExporting = true
    DispatchQueue.global(qos: .userInitiated).async {
        let pdfData = PDFGenerator.makeReportPDF(
            title:    "Farm Monthly Report",
            subtitle: selectedReport.monthYearLabel,   // e.g. "May 2026"
            rows:     vm.summaryRows(from: selectedReport),
            reports:  monthlyReports
        )
        // PDFGenerator.writeTempFile writes to .temporaryDirectory with .pdf extension
        let url = PDFGenerator.writeTempFile(pdfData, named: "farm_report")
        DispatchQueue.main.async {
            isExporting = false
            if let url = url { shareItems = [url]; showShare = true }
        }
    }
}
```

The export buttons reuse Week 9 components — no new button style needed:

```swift
private var exportButtons: some View {
    VStack(spacing: 12) {
        SectionHeader(title: "នាំចេញទិន្នន័យ",
                      icon: "square.and.arrow.up",
                      color: .blue)
        HStack(spacing: 12) {
            PrimaryButton(title: "CSV", icon: "tablecells",    color: .blue)   { exportCSV() }
            PrimaryButton(title: "PDF", icon: "doc.richtext",  color: .orange) { exportPDF() }
        }
        Text("ចែករំលែកតាម AirDrop, Mail, WhatsApp ឬ Files")
            .font(.caption).foregroundColor(.secondary)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
}
```

Sheet and loading overlay are applied on `NavigationView`:

```swift
.sheet(isPresented: $showShare) { ShareSheet(items: shareItems) }
.loadingOverlay(isLoading: isExporting)   // Week 9 modifier
```

> **Why `DispatchQueue.global`?** Building a PDF or a large CSV can take 50–200 ms on older
> devices. Running on the main thread would freeze the UI and trigger the "jank" watchdog.
> Always dispatch back to `.main` before touching any `@State`.

> **Why `PDFGenerator.writeTempFile` not a helper in the view?** Keeps file I/O inside the
> `PDFGenerator` service — the view never touches `FileManager` directly.

| What the farmer sees | Destination |
|---|---|
| AirDrop | Mac or another iPhone nearby |
| Mail | Attach as an email to an agronomist |
| Files | Save to iCloud Drive or local On My iPhone |
| WhatsApp / Telegram | Send in a chat if the app is installed |
| Print | AirPrint to any compatible printer |

---

## 🎨 UI / UX Suggestions

| Element | Suggestion |
|---|---|
| Tab icon | `chart.bar.doc.horizontal` SF Symbol; Khmer label *របាយការណ៍* |
| Month picker | Left/right chevrons with the month name centred — `< ឧសភា 2026 >` |
| Bar chart | Fixed height of 200 pt inside a `FarmCard` container from Week 9 |
| Legend | Horizontal `HStack` with green square (ចំណូល) and red square (ចំណាយ) |
| Summary card | Three rows — ចំណូល, ចំណាយ, ចំណេញ (green if positive, red if negative) |
| Export buttons | Two `PrimaryButton`s side by side — "CSV" (blue) and "PDF" (orange) |
| Share sheet trigger | `.sheet(isPresented: $showShare)` — standard iOS share UI, no custom chrome |

**Suggested SF Symbols:**

| Purpose | Symbol |
|---|---|
| Reports tab | `chart.bar.doc.horizontal` |
| CSV export | `tablecells` |
| PDF export | `doc.richtext` |
| Share | `square.and.arrow.up` |
| Month previous | `chevron.left` |
| Month next | `chevron.right` |
| Profit positive | `arrow.up.circle.fill` |
| Profit negative | `arrow.down.circle.fill` |

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Using `Swift Charts` | Won't compile on iOS 13–15 | Use `GeometryReader` + `BarShape: Shape` |
| Hardcoding bar pixel heights | Breaks on different screen sizes | Calculate `heightFraction = value / maxValue` then multiply by `geo.size.height` |
| Grouping by `entry.date!` directly | Two entries on the same month land in different buckets if times differ | Group by `Calendar.dateInterval(of: .month, for:).start` — the canonical month start |
| `selectedMonth = Date()` not month start | Can cause `selectedReport(from:)` to miss the current month near midnight | Init to `Calendar.current.dateInterval(of: .month, for: Date())!.start` |
| Using `!$0.isIncome` to detect expenses | Misleading — a transfer or void type would also match | Use `$0.isExpense` — the explicit computed property on `Transaction` |
| Not escaping double-quotes in CSV | A note containing `"quotation"` breaks RFC 4180 column parsing | Replace `"` with `""` and wrap the whole field in outer quotes |
| Passing raw `Data` to `UIActivityViewController` | No filename in Mail attachment; Files picker shows a generic blob | Write to `.temporaryDirectory` with a `.pdf` or `.csv` extension and pass the `URL` |
| Calling `UIActivityViewController` directly in SwiftUI | Requires `UIApplication.shared.windows` hacks that break on iOS 15+ | Wrap it in `UIViewControllerRepresentable` (= `ShareSheet`) and present with `.sheet` |
| Using `ShareLink` | iOS 16+ only | Use `ShareSheet: UIViewControllerRepresentable` |
| Running export on the main thread | Large CSV/PDF (200+ rows) freezes the UI | Dispatch to `DispatchQueue.global(qos: .userInitiated)`, then call back on `.main` |
| Calling `PDFGenerator` from inside `@ViewBuilder` | No active PDF renderer context — `UIGraphicsGetCurrentContext()` returns nil | Export only inside a button action, never inside `body` |
| `maxValue = 0` when there are no entries | Division by zero crashes `heightFraction` | Guard: `entries.flatMap { ... }.max() ?? 1` |
| Forgetting `ctx.beginPage()` | Blank PDF output | Always call `ctx.beginPage()` before drawing anything |
| Calling `suffix(6)` inside `BarChartView` itself | Makes the component less reusable — callers can't control how many months to show | Keep `BarChartView` generic; pass `Array(monthlyReports.suffix(6))` from the view |

---

*End of Week 10 Materials — Data Export & Reports*
