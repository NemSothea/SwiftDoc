# 🌾 SmartFarmer Assistant — Finance Module

A SwiftUI iOS app that helps farmers track income and expenses with a clean, category-aware finance system backed by Core Data.

---

## ✨ Features

### 💰 Transaction Management
- **Add transactions** with amount, type (income or expense), category, and an optional note
- **Edit transactions** at any time from the detail screen
- **Delete transactions** by swiping left on any row
- **Real-time balance** — income, expense, and net balance totals update instantly

### 🔍 Filtering
- Filter the transaction list by **All**, **Income**, or **Expense** using a segmented picker
- Filtered views update live as transactions are added or removed

### 📋 Transaction Detail
- Tap any row to see the full details of a transaction — amount, type, category, note, and date
- Hit **Edit** (កែប្រែ) from the detail screen to open an inline edit form

### 🗂️ Categories
- **Expense categories** — e.g. Seeds, Fertiliser, Equipment, Labour, Other
- **Income categories** — e.g. Crop Sales, Livestock, Subsidy, Other
- Category picker adapts automatically based on the selected transaction type

### 🗓️ Calendar Tab
- Log farm activities (planting, watering, spraying, harvesting, etc.) with dates and notes
- Mark activities as completed with a single tap
- Optional reminders per activity

---

## 📱 Screens

| Screen | Description |
|---|---|
| **Finance Tab** | Summary cards (income / expense / balance) + filterable transaction list |
| **Add Transaction** | Form to enter amount, type, category, and note |
| **Transaction Detail** | Full view of a single transaction with an Edit button |
| **Edit Transaction** | Pre-filled form to update an existing transaction |
| **Calendar Tab** | Farm activity list with completion toggle and add form |

---

## 🔄 How It Works

### Data Layer — Core Data
All transactions are persisted using **Core Data** through a shared `CoreDataManager`. Views use `@FetchRequest` to observe the database and re-render automatically on any change.

### ViewModel — `FarmViewModel`
A single `ObservableObject` injected via `.environmentObject()` provides:
- `addTransaction(amount:note:type:category:)` — creates and saves a new record
- `updateTransaction(_:amount:note:type:category:)` — edits an existing record
- `deleteTransaction(_:)` — removes a record
- `formatCurrency(_:)` and `formatDate(_:)` — shared formatting helpers
- `calculateTotalBalance(transactions:)` — sums income minus expense across a fetch result

### Navigation — `FinanceCoordinator`
A dedicated `ObservableObject` centralises navigation state for the Finance tab. It holds a single `selectedTransactionID: UUID?`:

```
nil  →  list is shown (no detail pushed)
UUID →  NavigationLink matching that ID activates → TransactionDetailView is pushed
```

This coordinator is created as `@StateObject` in `MainTabView` and read via `@EnvironmentObject` in child views, making programmatic navigation and deep linking straightforward.

### Real-Time Totals
`FinanceTabView` computes `totalIncome`, `totalExpense`, and `balance` directly from the `@FetchRequest` result. Because `@FetchRequest` is live, all three summary cards refresh the moment any transaction is saved or deleted.

---

## 🏗️ Project Structure

```
SmartFarmerAssistant/
├── ViewModels/
│   ├── FarmViewModel.swift          # CRUD + formatting helpers
│   └── FinanceCoordinator.swift     # Navigation state for Finance tab
└── Views/
    ├── FinanceTabView.swift          # Summary cards + filtered list
    ├── AddTransactionView.swift      # Add form (sheet)
    ├── EditTransactionView.swift     # Edit form (sheet)
    ├── TransactionDetailView.swift   # Detail screen (push)
    ├── TransactionRowView.swift      # Single row in the list
    ├── TransactionListView.swift     # Raw list (unfiltered)
    └── CalendarTabView.swift         # Farm activity calendar
```

---

## 🛠️ Requirements

- **iOS 13+**
- **Swift 5.5+**
- **Xcode 14+**
- No third-party dependencies — Core Data + SwiftUI only
