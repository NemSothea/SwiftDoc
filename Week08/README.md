# Week 8: Dashboard Tab (Project 5)
## DashboardTabView
## Topic: Aggregating data across modules into a single overview screen

---

**Learning Objectives**

By the end of this week, students will be able to:
- Fetch data from **multiple Core Data entities** in a single view using several `@FetchRequest` properties
- Compute cross-module summaries (monthly profit/loss) as pure Swift functions on a **ViewModel**
- Build a rich **summary card** with a conditional `LinearGradient` background
- Compose a scrollable dashboard from reusable section components
- Wire up **Quick Action** buttons that open Add sheets from any tab
- Update `MainTabView` to add a new tab **without breaking** existing deep links

---

## ⚠️ iOS API Rules (Quick Reference)

| Feature | Notes |
|---|---|
| Navigation | `NavigationView` (existing codebase convention) |
| View model | `class DashboardViewModel: ObservableObject` |
| State VM | `@StateObject var vm: DashboardViewModel` |
| Multiple fetches | Multiple `@FetchRequest` on the same view — each is independent |
| `LinearGradient` | `LinearGradient(colors:startPoint:endPoint:)` — iOS 15+ (project target: iOS 18+) |
| Generic section | `struct DashboardSection<Content: View>` + `@ViewBuilder` |

---

**Lesson Breakdown:**

| Lesson | Topic |
|--------|-------|
| 8.1 | Designing `DashboardViewModel` — monthly P&L, recent items, upcoming activities |
| 8.2 | Monthly Profit/Loss card — `LinearGradient`, conditional color, currency formatter |
| 8.3 | Reusable `DashboardSection` component with `@ViewBuilder` |
| 8.4 | Row views — `TransactionDashboardRow`, `ActivityDashboardRow`, `JournalDashboardRow` |
| 8.5 | Quick Actions — opening sheets from a dashboard button |

---

## 🗂 Folder Structure

```
SmartFarmerAssistantFinish/
└── Dashboard/
    ├── ViewModels/
    │   └── DashboardViewModel.swift        ← monthly P&L, recent/upcoming helpers
    └── Views/
        └── DashboardTabView.swift          ← root view + all subcomponents
```

> **Reused from earlier weeks:** `SummaryCard` from `FinanceTabView`, `AddTransactionView`,
> `AddActivityView`, `AddJournalEntryView`, and the shared `Formatters.swift` extensions
> are all used directly — no duplication.

---

## 🏛 Architecture

```
┌─────────────────── App launch ──────────────────────────────────┐
│  MainTabView                                                     │
│      Tab 0 → DashboardTabView   ← NEW this week                 │
│      Tab 1 → FinanceTabView                                      │
│      Tab 2 → CalendarTabView                                     │
│      Tab 3 → PestGuideTabView                                    │
│      Tab 4 → JournalTabView                                      │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────── User opens Dashboard tab ─────────────────────────┐
│  DashboardTabView                                               │
│      ├─ @StateObject vm = DashboardViewModel()                  │
│      ├─ @FetchRequest<Transaction>    (date, descending)        │
│      ├─ @FetchRequest<FarmActivity>   (date, ascending)         │
│      ├─ @FetchRequest<JournalEntry>   (date, descending)        │
│      │                                                          │
│      └─ ScrollView {                                            │
│           monthlyProfitLossCard      ← gradient + P&L figures  │
│           recentTransactionsSection  ← last 3 transactions      │
│           upcomingActivitiesSection  ← next 3 pending tasks     │
│           latestJournalSection       ← most recent entry        │
│           quickActionsSection        ← Add buttons (3)          │
│         }                                                       │
└─────────────────────────────────────────────────────────────────┘
                                │
                        Quick Action tapped
                                │
                  ┌─────────────┼─────────────┐
                  ▼             ▼             ▼
          AddTransactionView  AddActivityView  AddJournalEntryView
               (sheet)           (sheet)           (sheet)
```

**Key design rules:**
- The dashboard only **reads** — it never writes to Core Data directly
- All computation lives in `DashboardViewModel` as pure functions, not in the view
- Each section is wrapped in the reusable `DashboardSection` component
- `DashboardViewModel` receives `[Transaction]` / `[FarmActivity]` / `[JournalEntry]` arrays — it does NOT hold Core Data context

---

## 📚 Lesson 8.1: DashboardViewModel (30 minutes)

**Goal:** write a ViewModel that computes summaries from already-fetched arrays — same
"pure function" pattern as `JournalViewModel.filter(_:)` from Week 7.

### Why arrays, not `@FetchRequest`?

ViewModels are plain `ObservableObject` classes — they can't own `@FetchRequest` properties
(those are property wrappers that only work inside a SwiftUI `View`). The view fetches, the
ViewModel transforms:

```
View (FetchRequest)  →  [Entity]  →  ViewModel.someMethod([Entity])  →  display value
```

```swift
// Dashboard/ViewModels/DashboardViewModel.swift

class DashboardViewModel: ObservableObject {

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

    func recentTransactions(_ transactions: [Transaction], limit: Int = 3) -> [Transaction] {
        Array(transactions.prefix(limit))
    }

    func upcomingActivities(_ activities: [FarmActivity], limit: Int = 3) -> [FarmActivity] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return activities
            .filter { !$0.isCompleted && ($0.date ?? .distantPast) >= startOfToday }
            .sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }

    func latestEntry(_ entries: [JournalEntry]) -> JournalEntry? { entries.first }

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
```

| Design choice | Why |
|---|---|
| Pure functions that take arrays | Easy to unit test — no Core Data context needed |
| `currentMonthTransactions` as private helper | DRY — `monthlyIncome` and `monthlyExpense` both reuse it |
| `upcomingActivities` sorts ascending | Dashboard shows the *nearest* task first |
| `limit` parameter with default 3 | Callers can override; dashboard uses 3 without spelling it out |

---

## 📚 Lesson 8.2: Monthly Profit/Loss Card (45 minutes)

**Goal:** build a single-screen "hero card" that switches from green (profit) to red (loss)
and shows the three key numbers: net P&L, total income, total expense.

```swift
// Computed property that returns the card view
private var monthlyProfitLossCard: some View {
    let income  = viewModel.monthlyIncome(Array(transactions))
    let expense = viewModel.monthlyExpense(Array(transactions))
    let pl      = income - expense
    let isProfit = pl >= 0

    return VStack(alignment: .leading, spacing: 14) {
        // Header row
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ចំណេញ / ខាតប្រចាំខែ")
                    .font(.subheadline).foregroundColor(.white.opacity(0.85))
                Text(currentMonthLabel)
                    .font(.caption).foregroundColor(.white.opacity(0.65))
            }
            Spacer()
            Image(systemName: isProfit
                  ? "arrow.up.right.circle.fill"
                  : "arrow.down.right.circle.fill")
                .font(.title).foregroundColor(.white.opacity(0.8))
        }

        // Big P&L number
        Text(pl.formattedCurrency)
            .font(.system(size: 34, weight: .bold)).foregroundColor(.white)

        Divider().background(Color.white.opacity(0.3))

        // Income / Expense breakdown
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 2) {
                Text("ចំណូល").font(.caption).foregroundColor(.white.opacity(0.7))
                Text(income.formattedCurrency).font(.subheadline.bold()).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("ចំណាយ").font(.caption).foregroundColor(.white.opacity(0.7))
                Text(expense.formattedCurrency).font(.subheadline.bold()).foregroundColor(.white)
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
}
```

> **Why `local let` before `return`?** A computed property returning `some View` is a
> regular Swift function — you can declare local values before the `return` statement.
> This is NOT a `@ViewBuilder` context, so no restriction on `let` bindings.

> **Why `Color(red:green:blue:)` instead of `.green`?** The system `.green` tint changes
> with the user's accent colour and can look muted. Custom RGB colours stay consistent
> across all devices.

| Design choice | Why |
|---|---|
| `isProfit` flag computed once | Used for both the gradient and the SF Symbol — one computation, two usages |
| `.shadow` tinted green or red | The card appears to glow in the correct colour — free visual feedback |
| Income + Expense breakdown below the big number | User sees P&L at a glance, then drills into the two components |

---

## 📚 Lesson 8.3: Reusable `DashboardSection` Component (30 minutes)

**Goal:** avoid repeating the same "card frame + section header" across every section by
factoring it into a generic `DashboardSection<Content: View>` wrapper.

```swift
struct DashboardSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content  // ← accepts any SwiftUI content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Branded header
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            content()  // ← the caller's rows
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
```

Usage:

```swift
DashboardSection(title: "ប្រតិបត្តិការថ្មីៗ", icon: "dollarsign.circle.fill", color: .green) {
    ForEach(recent) { tx in TransactionDashboardRow(transaction: tx) }
}
```

> **Why `@ViewBuilder` on `content`?** Without it, the trailing closure can only contain
> a single expression. With `@ViewBuilder`, the closure becomes a SwiftUI "result builder" —
> you can write `if`, `ForEach`, multiple views, all without `return`.

| Design choice | Why |
|---|---|
| Generic `<Content: View>` | Works with any content — ForEach, a single row, or an empty-state view |
| `@ViewBuilder` closure | Lets callers use SwiftUI DSL syntax inside the section |
| `.shadow(color: .black.opacity(0.06))` | Subtle lift — consistent across all cards on any background |

---

## 📚 Lesson 8.4: Dashboard Row Views (30 minutes)

Three lightweight rows, one per data source. Each extracts exactly the fields a
dashboard viewer needs — no full-detail content.

### TransactionDashboardRow

| Field shown | Source |
|---|---|
| Icon (up = income, down = expense) | `transaction.type` |
| Note or category | `transaction.note ?? transaction.category` |
| Date | `transaction.date?.formattedMedium` |
| Amount (coloured) | `transaction.amount.formattedCurrency` |

### ActivityDashboardRow

| Field shown | Source |
|---|---|
| Activity-type icon | `iconForType(activity.activityType)` |
| Title | `activity.title` |
| Date | `activity.date?.formattedMedium` |
| Bell if reminder | `activity.reminderEnabled` |

### JournalDashboardRow

| Field shown | Source |
|---|---|
| Weather icon (tinted) | `entry.weatherTag.symbolName` + `.tint` |
| Title | `entry.displayTitle` |
| Snippet | `entry.snippet` (first 120 chars) |
| Date | `entry.date?.formattedMedium` |
| Photo count | `entry.photoDatas.count` |

---

## 📚 Lesson 8.5: Quick Actions (20 minutes)

**Goal:** three buttons that open the correct "Add" sheet, demonstrating that any view
can present sheets for any module — not just the module's own tab.

```swift
private var quickActionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        Label("សកម្មភាពរហ័ស", systemImage: "bolt.fill")
            .font(.headline).foregroundColor(.orange)

        HStack(spacing: 12) {
            QuickActionButton(title: "ចំណូល/ចំណាយ",
                              icon: "plus.circle.fill", color: .green) {
                showAddTransaction = true
            }
            QuickActionButton(title: "សកម្មភាព",
                              icon: "calendar.badge.plus", color: .blue) {
                showAddActivity = true
            }
            QuickActionButton(title: "កំណត់ហេតុ",
                              icon: "square.and.pencil", color: .purple) {
                showAddJournal = true
            }
        }
    }
    .padding(16)
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
}
```

The button component:

```swift
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2).foregroundColor(color)
                    .frame(width: 52, height: 52)
                    .background(color.opacity(0.12))
                    .cornerRadius(14)
                Text(title)
                    .font(.caption).foregroundColor(.primary)
                    .multilineTextAlignment(.center).lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())  // ← prevents the whole HStack turning blue
    }
}
```

> **Why `.buttonStyle(PlainButtonStyle())`?** The default button style turns the
> entire tap area blue on press. `PlainButtonStyle()` removes that — we handle
> our own visual feedback through the background circle.

---

## 🔧 Updating MainTabView

Adding a new tab requires two changes:

1. **Insert the new tab** as tag 0; shift existing tags from 0→1, 1→2, 2→3, 3→4.
2. **Update the notification deep link** — `selectedTab = 1` (Calendar) is now `selectedTab = 2`.

```swift
// Views/MainTabView.swift (Week 8)

TabView(selection: $selectedTab) {
    DashboardTabView()          // NEW — tag 0
        .tabItem { Label("ផ្ទាំងគ្រប់គ្រង", systemImage: "square.grid.2x2.fill") }
        .tag(0)
        ...

    FinanceTabView()            // was 0, now 1
        .tag(1)
    CalendarTabView()           // was 1, now 2
        .tag(2)
    PestGuideTabView()          // was 2, now 3
        .tag(3)
    JournalTabView()            // was 3, now 4
        .tag(4)
}
.onReceive(NotificationCenter.default.publisher(for: .didTapActivityNotification)) { _ in
    selectedTab = 2             // was 1 — Calendar is now at index 2
}
```

| Rule | Why |
|---|---|
| Always use explicit `.tag()` on each tab | Without tags, `TabView` uses implicit integer indices that break if you reorder tabs |
| Update **all** hardcoded tab indices after reordering | A single missed index = silent navigation bug (notification lands on wrong tab) |

---

## 🎨 UI / UX Suggestions

| Element | Suggestion |
|---|---|
| Tab icon | `square.grid.2x2.fill` SF Symbol, Khmer label *ផ្ទាំងគ្រប់គ្រង* |
| P&L card | Full-width gradient card — green when `pl >= 0`, red when negative |
| Section headers | Icon tinted with module's accent colour (green Finance, blue Calendar, purple Journal) |
| Empty states | Centered icon + short message — same style as CalendarTabView empty day |
| Row dividers | `Divider().padding(.leading, 52)` — aligned to the right of the icon column |
| Quick Action icons | Filled circle with `color.opacity(0.12)` background, `cornerRadius(14)` |
| Background | `Color(.systemGroupedBackground)` — the standard iOS "settings-style" page background |

**Suggested SF Symbols:**

| Purpose | Symbol |
|---|---|
| Dashboard tab | `square.grid.2x2.fill` |
| P&L positive | `arrow.up.right.circle.fill` |
| P&L negative | `arrow.down.right.circle.fill` |
| Finance section | `dollarsign.circle.fill` |
| Calendar section | `calendar.badge.clock` |
| Journal section | `book.fill` |
| Quick Actions header | `bolt.fill` |
| Add transaction | `plus.circle.fill` |
| Add activity | `calendar.badge.plus` |
| Add journal | `square.and.pencil` |

---

## 🌐 Cross-Module Data Flow

The Dashboard is a **read-only consumer** of all three data stores:

```
Finance Core Data   ──►  @FetchRequest<Transaction>  ──►  DashboardViewModel.monthly*(...)
Calendar Core Data  ──►  @FetchRequest<FarmActivity>  ──►  DashboardViewModel.upcomingActivities(...)
Journal Core Data   ──►  @FetchRequest<JournalEntry>  ──►  DashboardViewModel.latestEntry(...)
```

No shared ViewModel, no singleton — each module's data is fetched independently by the
Dashboard view and passed as a plain Swift array to the ViewModel for computation.

| Approach | Pro | Con |
|---|---|---|
| Dashboard fetches independently | Simple, self-contained | Three fetch requests on one view |
| Shared "AppViewModel" | One object with all data | Tight coupling between modules |
| Pass data from parent | Parent fetches once | Parent (MainTabView) becomes very large |

> **Rule of thumb:** for a dashboard that shows *summaries*, three independent
> `@FetchRequest` properties is the right trade-off. If the dashboard later needs
> to write to or react to all three modules in complex ways, reconsider.

---

### Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Forgetting `.tag()` after adding the new tab | Navigation breaks silently — notification jumps to wrong tab | Always use explicit integer tags |
| Computing P&L inside the `body` computed property | Logic buried in the view | Move to `DashboardViewModel` as a pure function |
| Holding `FetchedResults<T>` in the ViewModel | `@FetchRequest` only works inside a `View` | Pass `Array(results)` to the ViewModel method |
| Using `@EnvironmentObject(financeCoordinator)` in Dashboard | Dashboard doesn't navigate to transaction detail | Only inject dependencies you actually use |
| Missing `@ViewBuilder` on `DashboardSection.content` | Compiler error: "Closure containing a declaration cannot be used with result builder" | Add `@ViewBuilder` to the closure parameter |
| `.buttonStyle(.plain)` omitted on `QuickActionButton` | Entire button row turns blue on press | Add `.buttonStyle(PlainButtonStyle())` |

---

*End of Week 8 Materials — Dashboard Tab*
