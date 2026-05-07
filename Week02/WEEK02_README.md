# Week 02 — CoreData Persistence & CRUD

![iOS](https://img.shields.io/badge/iOS-13%2B-blue) ![CoreData](https://img.shields.io/badge/CoreData-✓-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![Xcode](https://img.shields.io/badge/Xcode-15%2B-blue)

> **Goal:** Save app data permanently with CoreData so records survive app restarts.

---

## 🎯 Learning Objectives

- Set up `NSPersistentContainer` with a singleton `CoreDataManager`
- Create CoreData entities in `.xcdatamodeld` and generate `NSManagedObject` subclasses
- Use `@FetchRequest` for automatic UI updates
- Implement full CRUD: Create, Read, Update, Delete
- Build a complete Finance Tab with summary cards and filter

---

## ⚡ Quick Reference

| File | Purpose |
|---|---|
| `Utilities/CoreDataManager.swift` | Singleton CoreData stack (`NSPersistentContainer`) |
| `SmartFarmerAssistantFinish.xcdatamodeld` | Entity schema (Transaction, FarmActivity, Pest, JournalEntry) |
| `Models/Transaction+CoreDataClass.swift` | `@objc(Transaction)` class declaration |
| `Models/Transaction+CoreDataProperties.swift` | `@NSManaged` property declarations |
| `ViewModels/FarmViewModel.swift` | CRUD methods: `addTransaction`, `updateTransaction`, `deleteTransaction` |
| `Views/FinanceTabView.swift` | Complete Finance tab with `@FetchRequest`, summary cards, filter |
| `Views/AddTransactionView.swift` | Add transaction sheet |
| `Views/EditTransactionView.swift` | Edit transaction sheet with pre-filled `@State` |

---

## ⚠️ iOS 13+ vs SwiftData

| Feature | ✅ CoreData (iOS 13+) | ❌ SwiftData (iOS 17+) |
|---|---|---|
| Model class | `NSManagedObject` subclass | `@Model class` |
| Query | `@FetchRequest` | `@Query` |
| Container setup | `NSPersistentContainer` | `.modelContainer()` |
| ViewModel | `class: ObservableObject` | `@Observable class` |
| Pass to views | `.environmentObject(vm)` | `.environment(vm)` |
| Read in views | `@EnvironmentObject var vm` | `@Environment(VM.self)` |
| Navigation | `NavigationView {}` | `NavigationStack {}` |

**This course uses CoreData — target is iOS 13+.**

---

## 📚 Lesson 2.1 — CoreData Stack Setup (45 min)

### ⚠️ Critical Rule: ONE container only

> Creating `NSPersistentContainer` twice (in App + CoreDataManager) causes a crash:
> `"Multiple NSEntityDescriptions claim the NSManagedObject subclass"`

```swift
// Utilities/CoreDataManager.swift
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()   // ← Singleton

    lazy var persistentContainer: NSPersistentContainer = {
        // Name MUST exactly match .xcdatamodeld filename
        let container = NSPersistentContainer(name: "SmartFarmerAssistantFinish")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData load failed: \(error)") }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext() {
        if context.hasChanges { try? context.save() }
    }
}
```

```swift
// App/SmartFarmerAssistantFinishApp.swift
@main
struct SmartFarmerAssistantFinishApp: App {
    let context = CoreDataManager.shared.context   // ✅ reuse shared container

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, context)
        }
    }
}
```

---

## 📚 Lesson 2.2 — Entity Design in Xcode (30 min)

1. **File → New → File → Data Model** → name it `SmartFarmerAssistantFinish.xcdatamodeld`
2. Add entities with attributes:

| Entity | Attributes |
|---|---|
| **Transaction** | `amount: Double`, `date: Date`, `note: String`, `type: String`, `category: String`, `id: UUID` |
| **FarmActivity** | `title: String`, `activityType: String`, `date: Date`, `notes: String`, `isCompleted: Boolean`, `reminderEnabled: Boolean`, `id: UUID` |
| **Pest** | `name: String`, `pestType: String`, `symptoms: String`, `treatment: String`, `prevention: String`, `imageName: String`, `isFavorite: Boolean`, `id: UUID` |
| **JournalEntry** | `date: Date`, `content: String`, `weather: String`, `photoData: Binary Data`, `location: String`, `id: UUID` |

3. For each entity: **Inspector → Codegen → Manual/None**
4. **Editor → Create NSManagedObject Subclass...**

---

## 📚 Lesson 2.3 — NSManagedObject Subclass (30 min)

```swift
// Models/Transaction+CoreDataClass.swift
@objc(Transaction)
public class Transaction: NSManagedObject { }

// Models/Transaction+CoreDataProperties.swift
extension Transaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    @NSManaged public var amount:   Double
    @NSManaged public var date:     Date?
    @NSManaged public var note:     String?
    @NSManaged public var type:     String?
    @NSManaged public var category: String?
    @NSManaged public var id:       UUID?
}
extension Transaction: Identifiable {}
```

> `@NSManaged` replaces `var amount = 0.0` — CoreData handles storage internally.

---

## 📚 Lesson 2.4 — @FetchRequest (45 min)

```swift
struct TransactionListView: View {
    // ✅ Automatically watches SQLite and refreshes UI on changes
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) var transactions: FetchedResults<Transaction>

    // Filtered request — filters at database level (faster than .filter{})
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "type == %@", "expense")
    ) var expenses: FetchedResults<Transaction>
}
```

**Auto-refresh flow:**
```
User saves data  →  viewContext.save()
    → @FetchRequest detects change
    → SwiftUI re-renders List automatically ✅
```

**NSPredicate vs Swift `.filter{}`:**

| | `NSPredicate` | Swift `.filter{}` |
|---|---|---|
| Runs in | SQLite (database) | Memory (after all rows loaded) |
| Performance | Only loads matching rows | Loads ALL rows first |
| Use for CoreData | ✅ Recommended | ❌ Avoid for large datasets |

---

## 📚 Lesson 2.5 — CRUD Operations (45 min)

### Create

```swift
func addTransaction(amount: Double, note: String, type: String, category: String) {
    let t = Transaction(context: context)
    t.amount = amount; t.date = Date(); t.note = note
    t.type = type; t.category = category; t.id = UUID()
    saveContext()
}
```

### Update

```swift
func updateTransaction(_ t: Transaction, amount: Double, note: String,
                       type: String, category: String) {
    t.amount = amount; t.note = note; t.type = type; t.category = category
    saveContext()   // without this, changes are lost on restart
}
```

### Delete

```swift
func deleteTransaction(_ t: Transaction) {
    context.delete(t)
    saveContext()
}
```

### EditTransactionView — Pre-fill `@State` from existing data

```swift
struct EditTransactionView: View {
    let transaction: Transaction
    @State private var amount: String

    // ✅ Use State(initialValue:) to pre-fill — normal @State var = "" starts empty
    init(transaction: Transaction) {
        self.transaction = transaction
        _amount = State(initialValue: String(transaction.amount))
    }
}
```

### `.sheet(item:)` vs `.sheet(isPresented:)`

```swift
// ✅ For EDIT forms — passes the item directly into the closure
.sheet(item: $selectedTransaction) { transaction in
    EditTransactionView(transaction: transaction)
}

// ✅ For ADD forms — simpler when no data needs to be passed
.sheet(isPresented: $showingAddTransaction) {
    AddTransactionView()
}
```

---

## 📚 Lesson 2.6 — Finance Tab Complete (45 min)

```swift
struct FinanceTabView: View {
    @EnvironmentObject private var viewModel: FarmViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var filterType = "all"
    @State private var selectedTransaction: Transaction? = nil

    // For summary cards (no predicate — all rows)
    @FetchRequest(entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) var allTransactions: FetchedResults<Transaction>

    var totalIncome:  Double { allTransactions.filter { $0.type == "income"  }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { allTransactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount } }
    var balance:      Double { totalIncome - totalExpense }

    var body: some View {
        NavigationView {                  // ✅ iOS 13+ NavigationView
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    SummaryCard(title: "ចំណូល",   amount: totalIncome,  color: .green, icon: "arrow.up.circle.fill")
                    SummaryCard(title: "ចំណាយ",   amount: totalExpense, color: .red,   icon: "arrow.down.circle.fill")
                    SummaryCard(title: "សមតុល្យ", amount: balance,      color: .blue,  icon: "equal.circle.fill")
                }.padding()

                Picker("Filter", selection: $filterType) {
                    Text("ទាំងអស់").tag("all")
                    Text("ចំណូល").tag("income")
                    Text("ចំណាយ").tag("expense")
                }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal)

                List {
                    ForEach(displayedTransactions, id: \.self) { t in
                        TransactionRowView(transaction: t, viewModel: viewModel)
                            .onTapGesture { selectedTransaction = t }
                    }
                    .onDelete(perform: deleteTransactions)
                }
                .sheet(item: $selectedTransaction) { t in
                    EditTransactionView(transaction: t)
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(viewModel)
                }
            }
            .navigationTitle("កំណត់ត្រាចំណាយចំណូល")
        }
    }
}
```

---

## 🚨 Common Issues & Fixes

| Issue | Cause | Fix |
|---|---|---|
| `"Cannot load model"` | `.xcdatamodeld` filename ≠ `NSPersistentContainer(name:)` | Match names exactly |
| `"Multiple commands produce"` | Codegen is not set to Manual/None | Entity → Codegen → **Manual/None** |
| Data not saving after restart | Missing `saveContext()` | Always call `saveContext()` after changes |
| `@FetchRequest` not refreshing UI | Wrong `managedObjectContext` in environment | Ensure `.environment(\.managedObjectContext, viewContext)` |
| Edit form fields start empty | Using `@State var x = ""` | Use `_x = State(initialValue: transaction.x)` in `init` |
| Crash: `Multiple NSEntityDescriptions` | Two `NSPersistentContainer` instances | Use only `CoreDataManager.shared.context` |

---

## 🏠 Mini-Project Assignment

| Requirement | Weight |
|---|---|
| CoreData stack set up (`.xcdatamodeld` + `CoreDataManager`) | 20% |
| All 4 entities with correct attributes | 20% |
| CRUD for Transaction (add, edit, delete) | 30% |
| Finance Tab with summary cards + filter | 20% |
| Data persists after app restart | 10% |

### Submission Checklist
- [ ] `.xcdatamodeld` file with 4 entities created
- [ ] `NSManagedObject` subclasses with `@NSManaged` properties
- [ ] Codegen set to `Manual/None` for all entities
- [ ] ONE `NSPersistentContainer` (in `CoreDataManager.shared` only)
- [ ] `addTransaction`, `updateTransaction`, `deleteTransaction` implemented
- [ ] Finance Tab shows summary cards and filter works
- [ ] Data persists after closing and reopening the app

---

*End of Week 02 — Ready for Navigation & Tab Coordination in Week 03 →*
