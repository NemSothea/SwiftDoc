# 🌾 Week 2: SwiftData Persistence

## Topic: Saving Data Permanently with SwiftData

### Learning Objectives
By the end of this week, students will be able to:
- Convert structs to SwiftData `@Model` classes
- Set up and configure `modelContainer`
- Use `@Query` to fetch and auto-update UI
- Perform CRUD operations on all four farm models
- Add sample data on first launch

---

## 📚 Lesson 2.1: SwiftData Fundamentals (45 minutes)

### 2.1.1 What is SwiftData?
- Apple's modern persistence framework (iOS 17+)
- Built on top of Core Data but with Swift-native syntax
- Works seamlessly with SwiftUI
- No separate mapping models or code generation

### 2.1.2 Converting Models to SwiftData

**Update each model file with @Model:**

```swift
// Models/Transaction.swift - Updated with @Model
import Foundation
import SwiftData

@Model  // Add this macro
final class Transaction {  // Must be a class, not struct
    var amount: Double
    var date: Date
    var note: String
    var type: String
    var category: String
    
    // @Attribute(.unique) for unique constraints (optional)
    @Attribute(.unique) var id: UUID
    
    // @Transient for properties NOT saved to database
    @Transient var isNewlyAdded = false
    
    init(amount: Double, date: Date = Date(), note: String = "", type: String, category: String) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.note = note
        self.type = type
        self.category = category
    }
}
```

**Key Changes:**
- `class` instead of `struct`
- Add `@Model` macro
- Add unique `id` property with `@Attribute(.unique)`
- Use `@Transient` for temporary properties

### 2.2.3 Setting Up Model Container

```swift
// App/SmartFarmerAssistantApp.swift - Updated
import SwiftUI
import SwiftData

@main
struct SmartFarmerAssistantApp: App {
    let container: ModelContainer
    
    init() {
        do {
            // Configure all models
            container = try ModelContainer(
                for: 
                    Transaction.self,
                    FarmActivity.self,
                    Pest.self,
                    JournalEntry.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(container)
    }
}
```

**Live Demo:** Show how to check if SwiftData is working (no errors = success!)

---

## 📚 Lesson 2.2: Working with ModelContext (45 minutes)

### 2.2.1 Understanding ModelContext
- Like a "scratchpad" for your data
- Tracks changes before saving
- Insert, delete, and update operations

### 2.2.2 Getting ModelContext in Views

```swift
// Method 1: @Environment property wrapper
struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    // ...
}

// Method 2: In ViewModel (more advanced)
@Observal class FarmViewModel {
    var modelContext: ModelContext?
    
    func setup(with context: ModelContext) {
        self.modelContext = context
    }
}
```

### 2.2.3 CRUD Operations Demo

```swift
// Create a helper view to test SwiftData
struct SwiftDataTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @State private var message = ""
    
    var body: some View {
        List {
            Section("Test Controls") {
                Button("Add Sample Transaction") {
                    addSampleTransaction()
                }
                
                Button("Print All Transactions") {
                    printTransactions()
                }
                
                Button("Delete All") {
                    deleteAllTransactions()
                }
            }
            
            Section("Current Data (\(transactions.count) items)") {
                ForEach(transactions) { transaction in
                    VStack(alignment: .leading) {
                        Text("\(transaction.categoryName): \(transaction.amount)")
                            .font(.headline)
                        Text(transaction.date.formatted())
                            .font(.caption)
                    }
                }
            }
            
            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.blue)
            }
        }
    }
    
    // CREATE
    func addSampleTransaction() {
        let transaction = Transaction(
            amount: Double.random(in: 10...100),
            date: Date(),
            note: "Sample",
            type: Bool.random() ? "expense" : "income",
            category: "គ្រាប់ពូជ"
        )
        
        modelContext.insert(transaction)
        
        do {
            try modelContext.save()
            message = "✅ Added: \(transaction.amount)"
        } catch {
            message = "❌ Error: \(error.localizedDescription)"
        }
    }
    
    // READ (done automatically by @Query)
    func printTransactions() {
        for t in transactions {
            print("📊 \(t.categoryName): \(t.amount)")
        }
        message = "Printed \(transactions.count) items to console"
    }
    
    // DELETE
    func deleteAllTransactions() {
        for transaction in transactions {
            modelContext.delete(transaction)
        }
        
        do {
            try modelContext.save()
            message = "🗑️ Deleted all"
        } catch {
            message = "❌ Error: \(error.localizedDescription)"
        }
    }
}
```

**Live Demo:** Add this test view temporarily to MainTabView and demonstrate CRUD operations.

---

## 📚 Lesson 2.3: @Query for Auto-Updating UI (45 minutes)

### 2.3.1 Basic @Query Usage

```swift
struct TransactionListView: View {
    // Simplest form - gets all transactions
    @Query private var transactions: [Transaction]
    
    // With sort
    @Query(sort: \Transaction.date, order: .reverse) 
    private var recentTransactions: [Transaction]
    
    // With filter
    @Query(filter: #Predicate<Transaction> { $0.type == "expense" })
    private var expenses: [Transaction]
    
    var body: some View {
        List {
            Section("All (\(transactions.count))") {
                ForEach(transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
            
            Section("Recent (\(recentTransactions.count))") {
                ForEach(recentTransactions.prefix(3)) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
            
            Section("Expenses (\(expenses.count))") {
                ForEach(expenses) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
        }
    }
}
```

### 2.3.2 Advanced @Query with Dynamic Filters

```swift
struct FilteredTransactionView: View {
    let minimumAmount: Double
    let transactionType: String
    
    // Dynamic filter using variable
    @Query private var transactions: [Transaction]
    
    init(minimumAmount: Double, transactionType: String) {
        self.minimumAmount = minimumAmount
        self.transactionType = transactionType
        
        // Create predicate dynamically
        let predicate = #Predicate<Transaction> { transaction in
            transaction.amount >= minimumAmount &&
            transaction.type == transactionType
        }
        
        _transactions = Query(filter: predicate, sort: \.date)
    }
    
    var body: some View {
        List(transactions) { transaction in
            Text("\(transaction.amount) - \(transaction.note)")
        }
    }
}
```

### 2.3.3 Building the Finance Tab with @Query

```swift
// Views/Finance/FinanceTabView.swift
import SwiftUI
import SwiftData

struct FinanceTabView: View {
    @Environment(FarmViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext
    
    // Queries for different views
    @Query(sort: \Transaction.date, order: .reverse) 
    private var allTransactions: [Transaction]
    
    @Query(filter: #Predicate<Transaction> { $0.type == "income" },
           sort: \Transaction.date, order: .reverse)
    private var incomes: [Transaction]
    
    @Query(filter: #Predicate<Transaction> { $0.type == "expense" },
           sort: \Transaction.date, order: .reverse)
    private var expenses: [Transaction]
    
    @State private var selectedFilter = 0 // 0=all, 1=income, 2=expense
    
    var displayedTransactions: [Transaction] {
        switch selectedFilter {
        case 1: return incomes
        case 2: return expenses
        default: return allTransactions
        }
    }
    
    var totalBalance: Double {
        let income = incomes.reduce(0) { $0 + $1.amount }
        let expense = expenses.reduce(0) { $0 + $1.amount }
        return income - expense
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Summary Card
                VStack(spacing: 12) {
                    Text("ប្រាក់សរុបបច្ចុប្បន្ន")
                        .font(.headline)
                    
                    Text(viewModel.formatCurrency(totalBalance))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(totalBalance >= 0 ? .green : .red)
                    
                    HStack {
                        Spacer()
                        VStack {
                            Text("ចំណូល")
                                .font(.caption)
                            Text(viewModel.formatCurrency(incomes.reduce(0) { $0 + $1.amount }))
                                .foregroundColor(.green)
                        }
                        Spacer()
                        VStack {
                            Text("ចំណាយ")
                                .font(.caption)
                            Text(viewModel.formatCurrency(expenses.reduce(0) { $0 + $1.amount }))
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    Text("ទាំងអស់").tag(0)
                    Text("ចំណូល").tag(1)
                    Text("ចំណាយ").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Transaction List
                List {
                    ForEach(displayedTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
            .navigationTitle("កំណត់ត្រាចំណាយចំណូល")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { /* Show add sheet */ }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            let transaction = displayedTransactions[index]
            modelContext.delete(transaction)
        }
        
        try? modelContext.save()
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    @Environment(FarmViewModel.self) private var viewModel
    
    var body: some View {
        HStack {
            // Category Icon
            Image(systemName: transaction.isExpense ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundColor(transaction.isExpense ? .red : .green)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(transaction.categoryName)
                    .font(.headline)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(viewModel.formatCurrency(transaction.amount))
                .font(.headline)
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}
```

**Live Demo:** Build this Finance tab with real-time updates as you add/delete transactions.

---

## 📚 Lesson 2.4: Adding Sample Data (45 minutes)

### 2.4.1 Creating a Data Preloader

```swift
// Utilities/SampleData.swift
import Foundation
import SwiftData

struct SampleData {
    static func preloadIfNeeded(modelContext: ModelContext) {
        // Check if we already have data
        let transactionDescriptor = FetchDescriptor<Transaction>()
        let count = (try? modelContext.fetchCount(transactionDescriptor)) ?? 0
        
        if count == 0 {
            print("📦 Preloading sample data...")
            preloadTransactions(modelContext)
            preloadPests(modelContext)
            // Add other preloads as needed
        }
    }
    
    static func preloadTransactions(_ context: ModelContext) {
        let sampleTransactions = [
            Transaction(amount: 50, date: Date().addingTimeInterval(-86400 * 2), note: "ទិញគ្រាប់ពូជ", type: "expense", category: "គ្រាប់ពូជ"),
            Transaction(amount: 100, date: Date().addingTimeInterval(-86400 * 5), note: "លក់បន្លែ", type: "income", category: "បន្លែ"),
            Transaction(amount: 30, date: Date().addingTimeInterval(-86400), note: "ទិញជី", type: "expense", category: "ជី"),
            Transaction(amount: 200, date: Date(), note: "លក់ស្រូវ", type: "income", category: "ស្រូវ-ដំណាំ"),
        ]
        
        for transaction in sampleTransactions {
            context.insert(transaction)
        }
        
        try? context.save()
    }
    
    static func preloadPests(_ context: ModelContext) {
        let pests = [
            Pest(
                name: "កណ្ដៀរស៊ីស្លឹក",
                pestType: "insect",
                symptoms: "ស្លឹកមានប្រហោង ឬត្រូវបានស៊ីអស់",
                treatment: "បាញ់ថ្នាំសម្លាប់សត្វល្អិត ឬប្រើអន្ទាក់ពន្លឺ",
                prevention: "ដាំដំណាំឆ្លាស់គ្នា ត្រួតពិនិត្យស្រែជាប្រចាំ"
            ),
            Pest(
                name: "ផ្សិតម្សៅ",
                pestType: "fungal",
                symptoms: "ស្លឹកមានពណ៌សដូចម្សៅ ស្លឹកកោង",
                treatment: "បាញ់ថ្នាំសម្លាប់ផ្សិត កាត់ផ្នែកដែលមានជំងឺចេញ",
                prevention: "កុំដាំក្រាស់ពេក ធានាខ្យល់ចេញចូលល្អ"
            ),
            // Add 3-5 more pests
        ]
        
        for pest in pests {
            context.insert(pest)
        }
        
        try? context.save()
    }
}
```

### 2.4.2 Calling Preloader at App Launch

```swift
// App/SmartFarmerAssistantApp.swift - Update init()
init() {
    do {
        container = try ModelContainer(
            for: Transaction.self,
            FarmActivity.self,
            Pest.self,
            JournalEntry.self
        )
        
        // Preload sample data on first launch
        Task { @MainActor in
            let context = container.mainContext
            SampleData.preloadIfNeeded(modelContext: context)
        }
    } catch {
        fatalError("Failed to create ModelContainer")
    }
}
```

### 2.4.3 Testing Data Persistence

Create a simple test view to verify data saves:

```swift
struct PersistenceTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @Query private var pests: [Pest]
    
    var body: some View {
        List {
            Section("Transactions: \(transactions.count)") {
                ForEach(transactions) { t in
                    Text("\(t.categoryName): \(t.amount)")
                }
            }
            
            Section("Pests: \(pests.count)") {
                ForEach(pests) { p in
                    Text(p.name)
                }
            }
            
            Button("Kill App (Test Persistence)") {
                // This doesn't actually kill, but shows instruction
                print("Close app from switcher to test persistence")
            }
        }
    }
}
```

**Live Demo:** 
1. Run app, verify sample data appears
2. Add a new transaction
3. Close app completely (from app switcher)
4. Reopen app - data should still be there!

---

## 🏠 Week 2 Mini-Project Assignment

### Task: Implement SwiftData Persistence for All Models

**Requirements:**

1. **Model Conversion (20%)**
   - Convert all 4 model structs to @Model classes
   - Add UUID with @Attribute(.unique) to each
   - Ensure no compilation errors

2. **Sample Data Preloader (25%)**
   - Create preload function for all 4 model types
   - Add at least:
     - 5 sample transactions (mix of income/expense)
     - 3 sample farm activities
     - 5 sample pests/diseases
     - 3 sample journal entries
   - Verify preloader only runs once

3. **Finance Tab Enhancement (30%)**
   - Complete FinanceTabView as shown in lesson
   - Display real data from SwiftData
   - Show correct totals and balances
   - Implement swipe-to-delete

4. **Add Transaction Screen (25%)**
   - Create a sheet for adding new transactions
   - Include:
     - Amount field (number pad)
     - Type picker (Expense/Income)
     - Category picker (changes based on type)
     - Date picker
     - Note field
     - Save button that inserts to SwiftData

**Bonus Challenge (Optional):**
- Add validation (amount > 0, category selected)
- Implement edit functionality
- Add a confirmation alert before delete

**Submission Checklist:**
- [ ] All models converted to @Model classes
- [ ] Sample data appears on first launch
- [ ] Adding new transaction works and persists
- [ ] Deleting transaction works
- [ ] Totals update automatically
- [ ] Code is clean and commented

---

## 🔍 Common Issues & Solutions

### Issue 1: "Class cannot be marked as @Model"
**Solution:** Ensure the class is `final` and all properties are compatible types.

### Issue 2: Data not persisting after app close
**Solution:** Check that you called `try? context.save()` after changes.