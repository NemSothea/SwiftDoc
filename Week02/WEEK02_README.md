# 🌾 Week 2 : Data Persistence with Core Data
## Topic: Saving Data Permanently with Core Data

---

**Learning Objectives**

By the end of this week, students will be able to:
- Convert models to Core Data entities
- Set up Core Data stack (NSPersistentContainer)
- Understand @FetchRequest for automatic UI updates
- Perform basic CRUD operations (Create, Read, Update, Delete)
- Work with Managed Object Context

---

## ⚠️ Important Note: SwiftData vs Core Data

**SwiftData** (iOS 17+ / Xcode 15+):
- Newer, simpler syntax
- Uses `@Model` macro
- Requires iOS 17 minimum

**Core Data** (iOS 3+ / All Xcode versions):
- Mature, stable framework
- Uses `NSManagedObject` subclasses
- Works with Xcode 13 and iOS 9+

Since you're using Xcode 13, we'll use **Core Data**.

---

## 📚 Lesson 2.1: Setting Up Core Data in Xcode 13 (45 minutes)

**2.1.1 Creating the Data Model File**

```
// Step 1: In Xcode, File → New → File...
// Step 2: Choose "Data Model" from Core Data section
// Step 3: Name it "SmartFarmerModel.xcdatamodeld"
// Step 4: Save in your project folder
```

**2.1.2 Setting Up Core Data Stack**

```swift
// App/SmartFarmerAssistantApp.swift (Updated for Core Data)
import SwiftUI
import CoreData

@main
struct SmartFarmerAssistantApp: App {
    // Core Data Persistent Container
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmartFarmerModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
```

**2.1.3 Creating Core Data Manager (Helper Class)**

```swift
// Utilities/CoreDataManager.swift
import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // Reference to AppDelegate's persistent container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmartFarmerModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Save context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
```

---

## 📚 Lesson 2.2: Creating Core Data Entities (45 minutes)

**2.2.1 Creating Entities in Data Model Editor**

Open `SmartFarmerModel.xcdatamodeld` and create these entities:

**Entity: Transaction**
```
Attributes:
- amount: Double
- date: Date
- note: String
- type: String
- category: String
- id: UUID (default value: $(UUID))
```

**Entity: FarmActivity**
```
Attributes:
- title: String
- activityType: String
- date: Date
- notes: String
- isCompleted: Boolean
- reminderEnabled: Boolean
- id: UUID
```

**Entity: Pest**
```
Attributes:
- name: String
- pestType: String
- symptoms: String
- treatment: String
- prevention: String
- imageName: String
- isFavorite: Boolean
- id: UUID
```

**Entity: JournalEntry**
```
Attributes:
- date: Date
- content: String
- weather: String
- photoData: Binary Data (allows external storage)
- location: String
- id: UUID
```

**2.2.2 Generating NSManagedObject Subclasses**

```
// Step 1: Click on the entity in data model editor
// Step 2: Editor → Create NSManagedObject Subclass...
// Step 3: Select your data model and entities
// Step 4: Xcode will generate files like:
// - Transaction+CoreDataClass.swift
// - Transaction+CoreDataProperties.swift
```

**2.2.3 Manual Model Classes (Alternative)**

If you prefer to write them manually:

```swift
// Models/Transaction+CoreDataClass.swift
import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {
    // Convenience initializer for creating new transactions
    convenience init(context: NSManagedObjectContext,
                     amount: Double,
                     date: Date = Date(),
                     note: String = "",
                     type: String,
                     category: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.amount = amount
        self.date = date
        self.note = note
        self.type = type
        self.category = category
        self.id = UUID()
    }
    
    // Computed properties (not stored in Core Data)
    var categoryName: String {
        if type == "expense" {
            return ExpenseCategory(rawValue: category)?.rawValue ?? category
        } else {
            return IncomeCategory(rawValue: category)?.rawValue ?? category
        }
    }
    
    var isExpense: Bool { type == "expense" }
    var isIncome: Bool { type == "income" }
}

// Models/Transaction+CoreDataProperties.swift
import Foundation
import CoreData

extension Transaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var type: String?
    @NSManaged public var category: String?
    @NSManaged public var id: UUID?
}

// Enums for categories (same as before)
enum TransactionType: String, CaseIterable {
    case expense = "ចំណាយ"
    case income = "ចំណូល"
}

enum ExpenseCategory: String, CaseIterable {
    case seeds = "គ្រាប់ពូជ"
    case fertilizer = "ជី"
    case labor = "កម្លាំងពលកម្ម"
    case tools = "ឧបករណ៍"
    case other = "ផ្សេងៗ"
}

enum IncomeCategory: String, CaseIterable {
    case vegetable = "បន្លែ"
    case fruit = "ផ្លែឈើ"
    case grain = "ស្រូវ-ដំណាំ"
    case livestock = "សត្វ"
    case other = "ផ្សេងៗ"
}
```

---

## 📚 Lesson 2.3: Understanding @FetchRequest for UI Updates (45 minutes)

**2.3.1 What is @FetchRequest?**

In Core Data, `@FetchRequest` automatically watches for changes in your data and updates the UI when changes occur.

```swift
import SwiftUI
import CoreData

struct TransactionListView: View {
    // Automatically fetches and watches for changes
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) var transactions: FetchedResults<Transaction>
    
    // Filtered fetch request
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "type == %@", "expense")
    ) var expenses: FetchedResults<Transaction>
    
    var body: some View {
        List {
            ForEach(transactions, id: \.self) { transaction in
                VStack(alignment: .leading) {
                    Text(transaction.note ?? "No note")
                        .font(.headline)
                    Text("Amount: \(transaction.amount)")
                        .font(.subheadline)
                }
            }
        }
    }
}
```

**2.3.2 Dynamic Fetch Requests**

```swift
struct DynamicFilterView: View {
    @State private var filterType = "expense"
    
    var body: some View {
        VStack {
            Picker("Type", selection: $filterType) {
                Text("Expense").tag("expense")
                Text("Income").tag("income")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Dynamic fetch request based on filterType
            FilteredTransactionList(filterType: filterType)
        }
    }
}

struct FilteredTransactionList: View {
    var filterType: String
    
    // Dynamic predicate based on filterType
    var fetchRequest: FetchRequest<Transaction>
    var transactions: FetchedResults<Transaction> {
        fetchRequest.wrappedValue
    }
    
    init(filterType: String) {
        self.filterType = filterType
        self.fetchRequest = FetchRequest(
            entity: Transaction.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
            predicate: NSPredicate(format: "type == %@", filterType)
        )
    }
    
    var body: some View {
        List(transactions, id: \.self) { transaction in
            TransactionRow(transaction: transaction)
        }
    }
}
```

**2.3.3 Using @FetchRequest in ViewModel**

```swift
@Observable
class FarmViewModel {
    // Core Data context
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // MARK: - CRUD Operations
    
    // Create
    func addTransaction(amount: Double, note: String, type: String, category: String) {
        let transaction = Transaction(context: context)
        transaction.amount = amount
        transaction.date = Date()
        transaction.note = note
        transaction.type = type
        transaction.category = category
        transaction.id = UUID()
        
        saveContext()
    }
    
    // Read - Usually done with @FetchRequest in views
    
    // Update
    func updateTransaction(_ transaction: Transaction, 
                          amount: Double? = nil,
                          note: String? = nil) {
        if let amount = amount {
            transaction.amount = amount
        }
        if let note = note {
            transaction.note = note
        }
        
        saveContext()
    }
    
    // Delete
    func deleteTransaction(_ transaction: Transaction) {
        context.delete(transaction)
        saveContext()
    }
    
    // Batch Delete
    func deleteAllTransactions() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            saveContext()
        } catch {
            print("Error deleting all transactions: \(error)")
        }
    }
    
    // Save context
    private func saveContext() {
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Helper Methods
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "៛"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "៛0"
    }
    
    // Get total balance (would normally use aggregation)
    func calculateTotalBalance(transactions: FetchedResults<Transaction>) -> Double {
        var total: Double = 0
        for transaction in transactions {
            if transaction.type == "income" {
                total += transaction.amount
            } else {
                total -= transaction.amount
            }
        }
        return total
    }
}
```

---

## 📚 Lesson 2.4: Building the Finance Tab with Core Data (45 minutes)

**2.4.1 Transaction Row View**

```swift
// Views/Finance/TransactionRowView.swift
import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let viewModel: FarmViewModel
    
    var body: some View {
        HStack {
            // Category Icon
            Circle()
                .fill(transaction.isExpense ? Color.red : Color.green)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: transaction.isExpense ? "arrow.down" : "arrow.up")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.categoryName)
                    .font(.headline)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let date = transaction.date {
                    Text(viewModel.formatDate(date))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
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

**2.4.2 Add Transaction Sheet**

```swift
// Views/Finance/AddTransactionView.swift
import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(FarmViewModel.self) private var viewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var amount = ""
    @State private var note = ""
    @State private var selectedType = "expense"
    @State private var selectedExpenseCategory = ExpenseCategory.other.rawValue
    @State private var selectedIncomeCategory = IncomeCategory.other.rawValue
    
    let types = ["expense", "income"]
    
    var body: some View {
        NavigationView {
            Form {
                // Amount Section
                Section(header: Text("ចំនួនទឹកប្រាក់")) {
                    TextField("0", text: $amount)
                        .keyboardType(.numberPad)
                }
                
                // Type Section
                Section(header: Text("ប្រភេទ")) {
                    Picker("ប្រភេទ", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type == "expense" ? "ចំណាយ" : "ចំណូល").tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Category Section
                Section(header: Text("ប្រភេទរង")) {
                    if selectedType == "expense" {
                        Picker("ជ្រើសរើស", selection: $selectedExpenseCategory) {
                            ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                                Text(category.rawValue).tag(category.rawValue)
                            }
                        }
                    } else {
                        Picker("ជ្រើសរើស", selection: $selectedIncomeCategory) {
                            ForEach(IncomeCategory.allCases, id: \.rawValue) { category in
                                Text(category.rawValue).tag(category.rawValue)
                            }
                        }
                    }
                }
                
                // Note Section
                Section(header: Text("កំណត់ចំណាំ")) {
                    TextField("បញ្ចូលកំណត់ចំណាំ...", text: $note)
                }
            }
            .navigationTitle("បន្ថែមប្រតិបត្តិការ")
            .navigationBarItems(
                leading: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("រក្សាទុក") {
                    saveTransaction()
                }
                .disabled(amount.isEmpty)
            )
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let category = selectedType == "expense" ? selectedExpenseCategory : selectedIncomeCategory
        
        // Create new transaction
        let transaction = Transaction(context: viewContext)
        transaction.amount = amountValue
        transaction.date = Date()
        transaction.note = note
        transaction.type = selectedType
        transaction.category = category
        transaction.id = UUID()
        
        // Save to Core Data
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
}
```

**2.4.3 Complete Finance Tab View**

```swift
// Views/Finance/FinanceTabView.swift
import SwiftUI
import CoreData

struct FinanceTabView: View {
    @Environment(FarmViewModel.self) private var viewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingAddTransaction = false
    @State private var filterType = "all"
    
    // Fetch all transactions
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) var allTransactions: FetchedResults<Transaction>
    
    // Filtered transactions based on selection
    var displayedTransactions: [Transaction] {
        switch filterType {
        case "expense":
            return allTransactions.filter { $0.type == "expense" }
        case "income":
            return allTransactions.filter { $0.type == "income" }
        default:
            return Array(allTransactions)
        }
    }
    
    // Calculate totals
    var totalIncome: Double {
        allTransactions
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        allTransactions
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpense
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary Cards
                HStack(spacing: 12) {
                    SummaryCard(
                        title: "ចំណូល",
                        amount: totalIncome,
                        color: .green,
                        icon: "arrow.up.circle.fill"
                    )
                    
                    SummaryCard(
                        title: "ចំណាយ",
                        amount: totalExpense,
                        color: .red,
                        icon: "arrow.down.circle.fill"
                    )
                    
                    SummaryCard(
                        title: "សមតុល្យ",
                        amount: balance,
                        color: .blue,
                        icon: "equal.circle.fill"
                    )
                }
                .padding()
                
                // Filter Picker
                Picker("តម្រង", selection: $filterType) {
                    Text("ទាំងអស់").tag("all")
                    Text("ចំណូល").tag("income")
                    Text("ចំណាយ").tag("expense")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Transactions List
                List {
                    ForEach(displayedTransactions, id: \.self) { transaction in
                        TransactionRowView(transaction: transaction, viewModel: viewModel)
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
            .navigationTitle("កំណត់ត្រាចំណាយចំណូល")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        for index in offsets {
            let transaction = displayedTransactions[index]
            viewContext.delete(transaction)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    @Environment(FarmViewModel.self) private var viewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(viewModel.formatCurrency(amount))
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
```

---

## 📚 Lesson 2.5: Complete CRUD Operations Demo (Remaining time)

**2.5.1 Creating Sample Data for Testing**

```swift
// Utilities/SampleData.swift
import CoreData
import Foundation

class SampleData {
    static func createSampleData(context: NSManagedObjectContext) {
        // Create sample expenses
        let expense1 = Transaction(context: context)
        expense1.amount = 50000
        expense1.date = Date()
        expense1.note = "ទិញគ្រាប់ពូជបន្លែ"
        expense1.type = "expense"
        expense1.category = ExpenseCategory.seeds.rawValue
        expense1.id = UUID()
        
        let expense2 = Transaction(context: context)
        expense2.amount = 20000
        expense2.date = Date().addingTimeInterval(-86400) // Yesterday
        expense2.note = "ទិញជី"
        expense2.type = "expense"
        expense2.category = ExpenseCategory.fertilizer.rawValue
        expense2.id = UUID()
        
        // Create sample income
        let income1 = Transaction(context: context)
        income1.amount = 150000
        income1.date = Date().addingTimeInterval(-172800) // 2 days ago
        income1.note = "លក់បន្លែ"
        income1.type = "income"
        income1.category = IncomeCategory.vegetable.rawValue
        income1.id = UUID()
        
        // Save
        do {
            try context.save()
        } catch {
            print("Error saving sample data: \(error)")
        }
    }
}
```

**2.5.2 Updating MainTabView to Use Core Data**

```swift
// Views/MainTabView.swift (Updated)
import SwiftUI
import CoreData

struct MainTabView: View {
    @State private var viewModel: FarmViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    init() {
        // Initialize viewModel with context
        _viewModel = State(initialValue: FarmViewModel(context: CoreDataManager.shared.context))
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            FinanceTabView()
                .tabItem {
                    Label("ហិរញ្ញវត្ថុ", systemImage: "dollarsign.circle")
                }
                .tag(0)
                .environment(\.managedObjectContext, viewContext)
            
            CalendarTabView()
                .tabItem {
                    Label("ប្រតិទិន", systemImage: "calendar")
                }
                .tag(1)
                .environment(\.managedObjectContext, viewContext)
            
            PestGuideTabView()
                .tabItem {
                    Label("សត្វល្អិត", systemImage: "bug")
                }
                .tag(2)
                .environment(\.managedObjectContext, viewContext)
            
            JournalTabView()
                .tabItem {
                    Label("កំណត់ហេតុ", systemImage: "book")
                }
                .tag(3)
                .environment(\.managedObjectContext, viewContext)
        }
        .environment(viewModel)
    }
}
```

**2.5.3 Debug Helper for Core Data**

```swift
// Utilities/CoreDataDebug.swift
import CoreData
import Foundation

struct CoreDataDebug {
    static func printDatabaseLocation() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("Document Directory: \(urls[0])")
    }
    
    static func countEntities(context: NSManagedObjectContext) {
        do {
            let transactionCount = try context.count(for: Transaction.fetchRequest())
            print("📊 Transaction count: \(transactionCount)")
        } catch {
            print("Error counting entities: \(error)")
        }
    }
}
```

---

## 🏠 Week 2 Mini-Project Assignment

### Task: Implement Core Data Persistence

**Requirements:**

**1. Core Data Setup (20%)**
- [ ] Create Data Model file with all 4 entities
- [ ] Generate or create NSManagedObject subclasses
- [ ] Set up Core Data stack in App file

**2. CRUD Operations (40%)**
- [ ] Implement Create (add new transactions)
- [ ] Implement Read (display with @FetchRequest)
- [ ] Implement Update (edit existing transactions)
- [ ] Implement Delete (swipe to delete)

**3. Finance Tab Completion (30%)**
- [ ] Add Transaction form works
- [ ] Summary cards show correct totals
- [ ] Filter by income/expense works
- [ ] Data persists after app restart

**4. Sample Data & Debug (10%)**
- [ ] Add option to load sample data
- [ ] Verify data is saved to device

**Bonus Challenge (Optional):**
- Add search functionality to filter transactions
- Implement charts showing income vs expense
- Add export to CSV feature

---

### Submission Checklist:

- [ ] Core Data model created with all 4 entities
- [ ] Can add, view, edit, and delete transactions
- [ ] Data persists after closing and reopening app
- [ ] Summary cards update automatically
- [ ] Filter functionality works correctly
- [ ] No crashes when saving/loading data

---

### Common Core Data Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Cannot load model" | Check model file name matches exactly |
| Data not saving | Call `try context.save()` after changes |
| @FetchRequest not updating | Ensure View has access to correct context |
| Crash when deleting | Check for duplicate deletions |
| Predicate not working | Verify attribute names match exactly |

---

### Key Differences: SwiftData vs Core Data

| Feature | SwiftData (Xcode 15+) | Core Data (Xcode 13) |
|---------|----------------------|---------------------|
| Syntax | `@Model` macro | `NSManagedObject` subclasses |
| Query | `@Query` | `@FetchRequest` |
| Setup | `.modelContainer()` | `NSPersistentContainer` |
| iOS Version | iOS 17+ | iOS 3+ |

---

*End of Week 2 Materials - Core Data Edition for Xcode 13*
