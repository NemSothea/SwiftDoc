// Dashboard/ViewModels/DashboardViewModel.swift
import Foundation
import CoreData

class DashboardViewModel: ObservableObject {

    // MARK: - Finance (current month)

    func monthlyIncome(_ transactions: [Transaction]) -> Double {
        currentMonthTransactions(transactions)
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
    }

    func monthlyExpense(_ transactions: [Transaction]) -> Double {
        currentMonthTransactions(transactions)
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }

    func monthlyProfitLoss(_ transactions: [Transaction]) -> Double {
        monthlyIncome(transactions) - monthlyExpense(transactions)
    }

    // MARK: - Recent Transactions

    func recentTransactions(_ transactions: [Transaction], limit: Int = 3) -> [Transaction] {
        Array(transactions.prefix(limit))
    }

    // MARK: - Upcoming Activities

    /// Activities that are not completed and whose date is today or later, capped at `limit`.
    func upcomingActivities(_ activities: [FarmActivity], limit: Int = 3) -> [FarmActivity] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return activities
            .filter { !$0.isCompleted && ($0.date ?? .distantPast) >= startOfToday }
            .sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Journal

    func latestEntry(_ entries: [JournalEntry]) -> JournalEntry? {
        entries.first
    }

    // MARK: - Private helpers

    private func currentMonthTransactions(_ transactions: [Transaction]) -> [Transaction] {
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.year, .month], from: Date())
        return transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            let comps = calendar.dateComponents([.year, .month], from: date)
            return comps.year == nowComps.year && comps.month == nowComps.month
        }
    }
}
