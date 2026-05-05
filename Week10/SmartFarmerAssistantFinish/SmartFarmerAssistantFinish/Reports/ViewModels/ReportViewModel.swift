// Reports/ViewModels/ReportViewModel.swift
import Foundation
import Combine

class ReportViewModel: ObservableObject {
    @Published var selectedMonth: Date = {
        let cal = Calendar.current
        return cal.dateInterval(of: .month, for: Date())!.start
    }()

    // MARK: - Monthly grouping

    /// Groups transactions by calendar month and returns all months sorted oldest→newest.
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

    /// Returns the report for `selectedMonth`, or a zero report if no data exists.
    func selectedReport(from reports: [MonthlyReport]) -> MonthlyReport {
        reports.first { Calendar.current.isDate($0.month, equalTo: selectedMonth, toGranularity: .month) }
            ?? MonthlyReport(month: selectedMonth, income: 0, expense: 0)
    }

    // MARK: - Month navigation

    func goToPreviousMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }

    func goToNextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }

    var canGoToNextMonth: Bool {
        let nextStart = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
        return nextStart <= Date()
    }

    // MARK: - CSV / PDF helpers

    /// Summary rows for the PDF table — (label, value) pairs.
    func summaryRows(from report: MonthlyReport) -> [(String, String)] {
        [
            ("ចំណូលសរុប:",    report.income.formattedCurrency),
            ("ចំណាយសរុប:",  report.expense.formattedCurrency),
            ("ចំណេញ / ខាត:", report.profit.formattedCurrency),
        ]
    }

    /// Transactions that fall inside `selectedMonth`.
    func transactions(
        for month: Date,
        from all: [Transaction]
    ) -> [Transaction] {
        let cal = Calendar.current
        return all.filter {
            guard let d = $0.date else { return false }
            return cal.isDate(d, equalTo: month, toGranularity: .month)
        }
    }
}
