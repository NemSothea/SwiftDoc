// Dashboard/Views/DashboardTabView.swift
import SwiftUI
import CoreData

struct DashboardTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = DashboardViewModel()

    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var transactions: FetchedResults<Transaction>

    @FetchRequest(
        entity: FarmActivity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FarmActivity.date, ascending: true)]
    ) private var activities: FetchedResults<FarmActivity>

    @FetchRequest(
        entity: JournalEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]
    ) private var journalEntries: FetchedResults<JournalEntry>

    @State private var showAddTransaction = false
    @State private var showAddActivity = false
    @State private var showAddJournal = false
    @State private var isRefreshing = false
    @State private var listAppeared = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    monthlyProfitLossCard
                        .fadeIn(delay: 0.1)
                    recentTransactionsSection
                        .fadeIn(delay: 0.2)
                    upcomingActivitiesSection
                        .fadeIn(delay: 0.3)
                    latestJournalSection
                        .fadeIn(delay: 0.4)
                    quickActionsSection
                        .fadeIn(delay: 0.5)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .refreshable {
                isRefreshing = true
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                isRefreshing = false
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    listAppeared = true
                }
            }
            .navigationTitle("ផ្ទាំងគ្រប់គ្រង")
            .accessibilityLabel("ផ្ទាំងគ្រប់គ្រង")
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showAddActivity) {
                AddActivityView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showAddJournal) {
                AddJournalEntryView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    // MARK: - Monthly P&L Card

    private var monthlyProfitLossCard: some View {
        let income  = viewModel.monthlyIncome(Array(transactions))
        let expense = viewModel.monthlyExpense(Array(transactions))
        let pl      = income - expense
        let isProfit = pl >= 0

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ចំណេញ / ខាតប្រចាំខែ")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                    Text(currentMonthLabel)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.65))
                }
                Spacer()
                Image(systemName: isProfit ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.8))
            }

            Text(pl.formattedCurrency)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)

            Divider()
                .background(Color.white.opacity(0.3))

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ចំណូល")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(income.formattedCurrency)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("ចំណាយ")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(expense.formattedCurrency)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: isProfit
                    ? [Color(red: 0.12, green: 0.7, blue: 0.55), Color(red: 0.0, green: 0.5, blue: 0.4)]
                    : [Color(red: 0.9, green: 0.28, blue: 0.28), Color(red: 0.7, green: 0.15, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: (isProfit ? Color.green : Color.red).opacity(0.35), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("ចំណេញ ចំណាយ ប្រចាំខែ \(pl.formattedCurrency)")
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        DashboardSection(title: "ប្រតិបត្តិការថ្មីៗ", icon: "dollarsign.circle.fill", color: .green) {
            let recent = viewModel.recentTransactions(Array(transactions))
            if recent.isEmpty {
                DashboardEmptyState(message: "មិនទាន់មានប្រតិបត្តិការ", icon: "tray")
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recent.enumerated()), id: \.element.id) { index, tx in
                        TransactionDashboardRow(transaction: tx)
                        if index < recent.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Upcoming Activities

    private var upcomingActivitiesSection: some View {
        DashboardSection(title: "សកម្មភាពខាងមុខ", icon: "calendar.badge.clock", color: .blue) {
            let upcoming = viewModel.upcomingActivities(Array(activities))
            if upcoming.isEmpty {
                DashboardEmptyState(message: "មិនមានសកម្មភាពខាងមុខ", icon: "calendar.badge.plus")
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(upcoming.enumerated()), id: \.element.id) { index, activity in
                        ActivityDashboardRow(activity: activity)
                        if index < upcoming.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Latest Journal Entry

    private var latestJournalSection: some View {
        DashboardSection(title: "កំណត់ហេតុចុងក្រោយ", icon: "book.fill", color: .purple) {
            if let entry = viewModel.latestEntry(Array(journalEntries)) {
                JournalDashboardRow(entry: entry)
            } else {
                DashboardEmptyState(message: "មិនទាន់មានកំណត់ហេតុ", icon: "book.badge.plus")
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("សកម្មភាពរហ័ស", systemImage: "bolt.fill")
                .font(.headline)
                .foregroundColor(.orange)
                .padding(.horizontal, 4)

            HStack(spacing: 12) {
                QuickActionButton(title: "ចំណូល/ចំណាយ", icon: "plus.circle.fill", color: .green) {
                    showAddTransaction = true
                }
                QuickActionButton(title: "សកម្មភាព", icon: "calendar.badge.plus", color: .blue) {
                    showAddActivity = true
                }
                QuickActionButton(title: "កំណត់ហេតុ", icon: "square.and.pencil", color: .purple) {
                    showAddJournal = true
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Helpers

    private var currentMonthLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        fmt.locale = Locale(identifier: "km_KH")
        return fmt.string(from: Date())
    }
}

// MARK: - DashboardSection

struct DashboardSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            content()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - DashboardEmptyState

struct DashboardEmptyState: View {
    let message: String
    let icon: String

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

// MARK: - TransactionDashboardRow

struct TransactionDashboardRow: View {
    let transaction: Transaction

    private var isIncome: Bool { transaction.type == "income" }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isIncome ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.title2)
                .foregroundColor(isIncome ? .green : .red)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.note?.isEmpty == false ? transaction.note! : (transaction.category ?? "—"))
                    .font(.subheadline)
                    .lineLimit(1)
                if let date = transaction.date {
                    Text(date.formattedMedium)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(transaction.amount.formattedCurrency)
                .font(.subheadline.bold())
                .foregroundColor(isIncome ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - ActivityDashboardRow

struct ActivityDashboardRow: View {
    let activity: FarmActivity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForType(activity.activityType))
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title ?? "—")
                    .font(.subheadline)
                    .lineLimit(1)
                if let date = activity.date {
                    Text(date.formattedMedium)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if activity.reminderEnabled {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func iconForType(_ type: String?) -> String {
        switch type {
        case "ដាំដំណាំ":  return "leaf.fill"
        case "ស្រោចទឹក":  return "drop.fill"
        case "បាញ់ថ្នាំ": return "sprinkler.and.droplets"
        case "ច្រូតកាត់": return "scissors"
        default:           return "ellipsis.circle"
        }
    }
}

// MARK: - JournalDashboardRow

struct JournalDashboardRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.weatherTag.symbolName)
                .font(.title2)
                .foregroundColor(entry.weatherTag.tint)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayTitle)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(entry.snippet)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                if let date = entry.date {
                    Text(date.formattedMedium)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            let photoCount = entry.photoDatas.count
            if photoCount > 0 {
                Label("\(photoCount)", systemImage: "photo")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - QuickActionButton

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 52, height: 52)
                    .background(color.opacity(0.12))
                    .cornerRadius(14)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .scalePress()
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
    }
}
