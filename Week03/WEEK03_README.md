# 🌾 Week 3 : Navigation & Tab Coordination
## Topic: Building a Professional Navigation System

---

**Learning Objectives**

By the end of this week, students will be able to:
- Use `NavigationView` and `NavigationLink` for stack-based navigation (iOS 13+)
- Build list → detail navigation for transactions
- Create a `NavigationCoordinator` using `ObservableObject` to centralise navigation state
- Drive navigation programmatically with `NavigationLink(tag:selection:)`
- Simulate deep linking: jumping to a specific screen from outside the tab

---

## ⚠️ iOS 13+ Navigation API Rules (Important!)

| Feature | ❌ iOS 16+ Only | ✅ iOS 13+ Correct |
|---|---|---|
| Navigation container | `NavigationStack` | `NavigationView` |
| Programmatic nav | `NavigationPath` | `@State var selectedID: UUID?` + `tag/selection` |
| Navigation destination | `.navigationDestination(for:)` | `NavigationLink(destination:)` |
| Navigation title | `.navigationTitle` (same ✅) | `.navigationTitle` |
| Dismiss | `@Environment(\.dismiss)` | `@Environment(\.presentationMode)` |

---

## 📚 Lesson 3.1: NavigationView & NavigationLink Basics (30 minutes)

### 3.1.1 NavigationView — The Navigation Container

Every tab that needs push navigation must be wrapped in a `NavigationView`.

```swift
// ✅ iOS 13+ — wrap the tab's root view in NavigationView
struct FinanceTabView: View {
    var body: some View {
        NavigationView {
            List { ... }
                .navigationTitle("ហិរញ្ញវត្ថុ")
        }
    }
}

// ❌ iOS 16+ only
struct FinanceTabView: View {
    var body: some View {
        NavigationStack { ... }
    }
}
```

> ⚠️ **Rule:** Each tab creates its own `NavigationView`. Never share one `NavigationView` across all tabs — each tab needs its own independent navigation stack.

---

### 3.1.2 NavigationLink — Pushing a Detail View

`NavigationLink` wraps a row and pushes a destination view when tapped.

```swift
// Basic NavigationLink — tapping the row pushes DetailView
NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
    TransactionRowView(transaction: transaction)
}
```

**How it works:**
1. The `destination:` is the view to push onto the stack
2. The `label:` (trailing closure) is what the user sees and taps
3. The back button is provided automatically by `NavigationView`

---

## 📚 Lesson 3.2: List → Detail Navigation (30 minutes)

### 3.2.1 The Pattern

```
FinanceTabView (list)
    └── NavigationLink
            └── TransactionDetailView (detail)
                    └── EditTransactionView (sheet, for editing)
```

Each level has a clear responsibility:
- **List** — shows all records, lets user browse and delete
- **Detail** — shows one record in full, has an "Edit" button
- **Edit sheet** — modifies the record

### 3.2.2 TransactionDetailView

The detail view receives a `Transaction` object and displays all its fields.

```swift
// Views/TransactionDetailView.swift
struct TransactionDetailView: View {
    @EnvironmentObject private var viewModel: FarmViewModel
    @Environment(\.managedObjectContext) private var viewContext

    let transaction: Transaction          // passed from the list
    @State private var showingEdit = false

    var body: some View {
        Form {
            Section(header: Text("ចំនួនទឹកប្រាក់")) {
                Text(viewModel.formatCurrency(transaction.amount))
                    .foregroundColor(transaction.isExpense ? .red : .green)
            }

            Section(header: Text("ប្រភេទ")) {
                HStack {
                    Text("ប្រភេទ").foregroundColor(.gray)
                    Spacer()
                    Text(transaction.isExpense ? "ចំណាយ" : "ចំណូល")
                }
                HStack {
                    Text("ប្រភេទរង").foregroundColor(.gray)
                    Spacer()
                    Text(transaction.categoryName)
                }
            }
        }
        .navigationTitle("ព័ត៌មានប្រតិបត្តិការ")
        .navigationBarItems(trailing: Button("កែប្រែ") {
            showingEdit = true
        })
        .sheet(isPresented: $showingEdit) {
            EditTransactionView(transaction: transaction)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(viewModel)
        }
    }
}
```

> ✅ **Why a separate detail view?** The list should only show summary rows. The detail view focuses on one record — easy to extend later (add photos, share button, etc.) without touching the list.

---

## 📚 Lesson 3.3: NavigationCoordinator Pattern (45 minutes)

### 3.3.1 The Problem with Scattered Navigation State

Without a coordinator, each view manages its own `@State` for navigation:

```swift
// ❌ Navigation state scattered across views
struct FinanceTabView: View {
    @State private var selectedTransaction: Transaction? = nil  // one state here
    @State private var showingAddTransaction = false             // another state here
    // Hard to drive from outside (e.g., deep links, notifications)
}
```

This becomes fragile when you need to **trigger navigation from outside** the view — for example, when the user taps a notification and the app should jump to a specific transaction.

### 3.3.2 The Coordinator Solution

Move all navigation state into a single `ObservableObject`:

```swift
// ViewModels/FinanceCoordinator.swift
import SwiftUI

class FinanceCoordinator: ObservableObject {

    // The UUID of the currently-selected transaction.
    // nil  → list is shown (nothing pushed)
    // UUID → NavigationLink matching this ID activates → detail pushed
    @Published var selectedTransactionID: UUID? = nil

    // Navigate to a specific transaction (call from anywhere)
    func navigate(to transaction: Transaction) {
        selectedTransactionID = transaction.id
    }

    // Pop back to the list
    func reset() {
        selectedTransactionID = nil
    }
}
```

### 3.3.3 Wiring the Coordinator

**Step 1 — Create in MainTabView (root owner):**

```swift
// Views/MainTabView.swift
struct MainTabView: View {
    @StateObject private var viewModel: FarmViewModel
    @StateObject private var financeCoordinator = FinanceCoordinator()  // ← created here
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FinanceTabView()
                .tabItem { Label("ហិរញ្ញវត្ថុ", systemImage: "dollarsign.circle") }
                .tag(0)
            // ...other tabs
        }
        .environmentObject(viewModel)
        .environmentObject(financeCoordinator)  // ← injected here
    }
}
```

**Step 2 — Read in FinanceTabView:**

```swift
// Views/FinanceTabView.swift
struct FinanceTabView: View {
    @EnvironmentObject private var viewModel: FarmViewModel
    @EnvironmentObject private var coordinator: FinanceCoordinator  // ← read here

    var body: some View {
        NavigationView {
            FilteredTransactionList(
                filterType: filterType,
                viewModel: viewModel,
                selectedTransactionID: $coordinator.selectedTransactionID  // ← pass binding
            )
        }
    }
}
```

> ✅ **Key rule:** `@StateObject` creates and owns the object. `@EnvironmentObject` reads a copy that was injected by a parent. Only ONE place should use `@StateObject` for each coordinator — that is `MainTabView`.

---

## 📚 Lesson 3.4: Programmatic Navigation with tag/selection (30 minutes)

### 3.4.1 NavigationLink(tag:selection:)

Instead of relying on a tap gesture, this variant of `NavigationLink` activates when a `@Binding` variable matches the `tag` value.

```swift
// In FilteredTransactionList
ForEach(transactions, id: \.self) { transaction in
    NavigationLink(
        destination: TransactionDetailView(transaction: transaction),
        tag: transaction.id ?? UUID(),      // unique identifier for this link
        selection: $selectedTransactionID   // binding owned by FinanceCoordinator
    ) {
        TransactionRowView(transaction: transaction, viewModel: viewModel)
    }
}
```

**How activation works:**

| `selectedTransactionID` value | Result |
|---|---|
| `nil` | No detail view is pushed (list visible) |
| matches a row's `tag` | That `NavigationLink` activates → detail pushed |
| set by code (not tap) | Same effect — this enables deep linking |

### 3.4.2 Comparing the Two NavigationLink Styles

```swift
// Style A — simple, tap-only
NavigationLink(destination: DetailView(item: item)) {
    RowView(item: item)
}

// Style B — programmatic, works with tag/selection
NavigationLink(
    destination: DetailView(item: item),
    tag: item.id,
    selection: $selectedID
) {
    RowView(item: item)
}
```

Use **Style A** for simple read-only navigation.
Use **Style B** when you need to trigger navigation from outside (notifications, deep links, dashboards).

---

## 📚 Lesson 3.5: Deep Linking Simulation (20 minutes)

### 3.5.1 What is Deep Linking?

Deep linking means jumping directly to a specific screen from outside the current context — for example:
- User taps a local notification → app opens the relevant activity
- Dashboard card tapped → jumps to Finance tab and opens a specific transaction
- App launched with a URL → navigates to the correct screen

### 3.5.2 Simulating a Deep Link

In `MainTabView`, add a helper method:

```swift
// Views/MainTabView.swift
func deepLink(to transactionID: UUID) {
    selectedTab = 0                                        // 1. Switch to Finance tab
    financeCoordinator.selectedTransactionID = transactionID  // 2. Activate the NavigationLink
}
```

Because `financeCoordinator` is `@StateObject` in `MainTabView` and `@EnvironmentObject` in `FinanceTabView`, setting `selectedTransactionID` from the coordinator in `MainTabView` flows down to the `NavigationLink(tag:selection:)` in `FilteredTransactionList` automatically.

**Data flow diagram:**

```
MainTabView
  ├── @StateObject financeCoordinator
  │         ↓ .environmentObject(financeCoordinator)
  └── FinanceTabView
            ↓ @EnvironmentObject coordinator
        FilteredTransactionList
            ↓ $coordinator.selectedTransactionID
        NavigationLink(tag: uuid, selection: $selectedTransactionID)
            ↓ activates when selectedTransactionID == uuid
        TransactionDetailView
```

> ✅ The coordinator is the **single source of truth** for Finance tab navigation. Any component in the tree can trigger navigation by mutating `coordinator.selectedTransactionID`.

---

## 🔨 Live Coding Walkthrough

### Step 1 — Create FinanceCoordinator

Create `ViewModels/FinanceCoordinator.swift`:

```swift
import SwiftUI

class FinanceCoordinator: ObservableObject {
    @Published var selectedTransactionID: UUID? = nil

    func navigate(to transaction: Transaction) {
        selectedTransactionID = transaction.id
    }

    func reset() {
        selectedTransactionID = nil
    }
}
```

### Step 2 — Create TransactionDetailView

Create `Views/TransactionDetailView.swift` with a `Form` showing amount, type, category, note, and date. Add a "កែប្រែ" (Edit) toolbar button that presents `EditTransactionView` as a sheet.

### Step 3 — Update FilteredTransactionList

Replace the `onTap` callback with `NavigationLink(tag:selection:)`:

```swift
// Before (Week 2)
init(filterType: String, viewModel: FarmViewModel, onTap: @escaping (Transaction) -> Void)

// After (Week 3)
init(filterType: String, viewModel: FarmViewModel, selectedTransactionID: Binding<UUID?>)
```

Inside `body`, replace `.onTapGesture` with `NavigationLink(tag:selection:destination:label:)`.

### Step 4 — Update FinanceTabView

- Remove `@State private var selectedTransaction: Transaction?`
- Add `@EnvironmentObject private var coordinator: FinanceCoordinator`
- Pass `$coordinator.selectedTransactionID` to `FilteredTransactionList`
- Remove the `.sheet(item: $selectedTransaction)` for editing (editing now lives in `TransactionDetailView`)

### Step 5 — Update MainTabView

- Add `@StateObject private var financeCoordinator = FinanceCoordinator()`
- Append `.environmentObject(financeCoordinator)` to the `TabView`
- Add the `deepLink(to:)` helper

### Step 6 — Test Navigation

Run the app and verify:
1. Tapping a transaction row pushes `TransactionDetailView` ✅
2. The back button pops back to the list ✅
3. The "កែប្រែ" button opens the edit sheet ✅
4. Saving edits updates the detail view immediately ✅

---

## ✅ Mini-Project

1. Complete all 5 steps above so the Finance tab has full list → detail navigation
2. Verify the detail view shows all fields: amount, type, category, note, date
3. Confirm editing from the detail view works and the changes appear immediately on return
4. Add a "Deep Link Demo" button somewhere (e.g., temporarily in `MainTabView` or `CalendarTabView`) that calls `deepLink(to: firstTransactionID)` to prove programmatic navigation works
5. **Bonus:** Apply the same `NavigationLink(destination:)` pattern to `CalendarTabView` — add an `ActivityDetailView` that shows a `FarmActivity` in full

---

## 📝 Key Concepts Summary

| Concept | Code | Purpose |
|---|---|---|
| Navigation container | `NavigationView { }` | Wraps the root of each tab |
| Push link (tap-only) | `NavigationLink(destination:)` | Simple list → detail |
| Push link (programmatic) | `NavigationLink(tag:selection:)` | Enables deep linking |
| Coordinator | `class FC: ObservableObject` | Single source of truth for nav state |
| Create coordinator | `@StateObject var c = FC()` | In the parent (MainTabView) |
| Read coordinator | `@EnvironmentObject var c: FC` | In child views |
| Inject coordinator | `.environmentObject(c)` | On the TabView in MainTabView |
| Pop to root | `coordinator.reset()` | Sets selectedTransactionID = nil |

---

## ⚠️ Common Mistakes

**1. Creating NavigationView inside a sheet**

```swift
// ❌ EditTransactionView already embeds its own NavigationView
// Don't wrap it in another NavigationView in the parent
.sheet(isPresented: $showingEdit) {
    NavigationView {           // ← extra, causes double nav bar
        EditTransactionView(...)
    }
}

// ✅ Just present the view directly
.sheet(isPresented: $showingEdit) {
    EditTransactionView(...)   // EditTransactionView handles its own NavigationView
}
```

**2. Using @StateObject instead of @EnvironmentObject in child views**

```swift
// ❌ This creates a NEW independent coordinator, not the one from MainTabView
struct FinanceTabView: View {
    @StateObject private var coordinator = FinanceCoordinator()
}

// ✅ Read the coordinator injected by MainTabView
struct FinanceTabView: View {
    @EnvironmentObject private var coordinator: FinanceCoordinator
}
```

**3. Missing .environmentObject() injection**

If you read a coordinator with `@EnvironmentObject` but forget to inject it, the app crashes with:
```
Fatal error: No ObservableObject of type FinanceCoordinator found.
```
Fix: ensure `.environmentObject(financeCoordinator)` is present on the `TabView` in `MainTabView`.
