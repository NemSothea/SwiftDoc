
# 🌾 Week 1: Project Setup & MVVM Architecture

## Topic: Laying the Foundation with Clean Architecture

### Learning Objectives
By the end of this week, students will be able to:
- Set up a professional Xcode project with proper folder structure
- Understand and implement MVVM architecture with the new `@Observable` macro
- Create Swift data models for agricultural tracking
- Build a tab-based navigation interface
- Connect basic UI to a ViewModel

---

## 📚 Lesson 1.1: Xcode Project Setup & Organization (45 minutes)

### 1.1.1 Creating the Project
```swift
// Step 1: Open Xcode → Create New Project → iOS → App
// Step 2: Configure project:
// - Product Name: SmartFarmerAssistant
// - Team: (Your team)
// - Organization Identifier: com.yourname
// - Interface: SwiftUI
// - Language: Swift
// - Lifecycle: SwiftUI App
// - Core Data: Unchecked (we'll use SwiftData)
```

### 1.1.2 Professional Folder Structure
Create the following folder structure in the project navigator:

```
SmartFarmerAssistant/
├── App/
│   └── SmartFarmerAssistantApp.swift
├── Models/
│   ├── Transaction.swift
│   ├── FarmActivity.swift
│   ├── Pest.swift
│   └── JournalEntry.swift
├── ViewModels/
│   └── FarmViewModel.swift
├── Views/
│   ├── MainTabView.swift
│   ├── Finance/
│   │   ├── FinanceTabView.swift
│   │   └── TransactionRowView.swift
│   ├── Calendar/
│   │   └── CalendarTabView.swift
│   ├── PestGuide/
│   │   └── PestGuideTabView.swift
│   └── Journal/
│       └── JournalTabView.swift
├── Utilities/
│   ├── Extensions/
│   └── Constants.swift
└── Resources/
    └── Assets.xcassets
```

**Live Demo:** Create each folder and explain the purpose of each directory.

### 1.1.3 Creating the App Entry Point
```swift
// App/SmartFarmerAssistantApp.swift
import SwiftUI
import SwiftData

@main
struct SmartFarmerAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [
            Transaction.self,
            FarmActivity.self,
            Pest.self,
            JournalEntry.self
        ])
    }
}
```

**Explanation:** 
- `@main` identifies the entry point
- `modelContainer` sets up SwiftData for all our models (we'll define them next week)
- `MainTabView()` will be our root view

---

## 📚 Lesson 1.2: Understanding MVVM with @Observable (45 minutes)

### 1.2.1 What is MVVM?
- **Model**: Data structures (Transaction, FarmActivity, etc.)
- **View**: SwiftUI views (what user sees)
- **ViewModel**: Business logic, connects Model and View

### 1.2.2 The New @Observable Macro (iOS 17+)
```swift
// Before (iOS 16 and earlier)
class OldViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
}

// After (iOS 17+) - Simpler and more efficient
@Observable
class FarmViewModel {
    var transactions: [Transaction] = []
    var isLoading = false
    var selectedTab = 0
    
    // Computed properties also trigger view updates
    var totalBalance: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
}
```

**Key Points:**
- No more `@Published` wrapper
- No more `ObservableObject` conformance
- Any property change automatically updates views
- Better performance (only observed properties trigger updates)

### 1.2.3 Using @Observable in Views
```swift
struct ContentView: View {
    // @State for local view state
    @State private var viewModel = FarmViewModel()
    
    var body: some View {
        VStack {
            Text("Balance: $\(viewModel.totalBalance)")
            
            // Bind directly to properties
            Picker("Tab", selection: Bindable(viewModel).selectedTab) {
                Text("Finance").tag(0)
                Text("Calendar").tag(1)
            }
        }
    }
}
```

**Live Demo:** Create a simple counter app to demonstrate @Observable in action.

---

## 📚 Lesson 1.3: Creating Core Data Models (45 minutes)

### 1.3.1 Transaction Model (for Finance Tracker)
```swift
// Models/Transaction.swift
import Foundation
import SwiftData

enum TransactionType: String, CaseIterable {
    case expense = "ចំណាយ"      // Expense
    case income = "ចំណូល"       // Income
}

enum ExpenseCategory: String, CaseIterable {
    case seeds = "គ្រាប់ពូជ"        // Seeds
    case fertilizer = "ជី"           // Fertilizer
    case labor = "កម្លាំងពលកម្ម"    // Labor
    case tools = "ឧបករណ៍"          // Tools
    case other = "ផ្សេងៗ"           // Other
}

enum IncomeCategory: String, CaseIterable {
    case vegetable = "បន្លែ"         // Vegetables
    case fruit = "ផ្លែឈើ"           // Fruits
    case grain = "ស្រូវ-ដំណាំ"      // Grains/Crops
    case livestock = "សត្វ"          // Livestock
    case other = "ផ្សេងៗ"           // Other
}

@Model
class Transaction {
    var amount: Double
    var date: Date
    var note: String
    var type: String  // "expense" or "income"
    var category: String
    
    init(amount: Double, date: Date = Date(), note: String = "", type: String, category: String) {
        self.amount = amount
        self.date = date
        self.note = note
        self.type = type
        self.category = category
    }
    
    // Computed property for display
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
```

### 1.3.2 FarmActivity Model (for Calendar/Reminders)
```swift
// Models/FarmActivity.swift
import Foundation
import SwiftData

enum ActivityType: String, CaseIterable {
    case planting = "ដាំ"           // Planting
    case watering = "ស្រោចទឹក"     // Watering
    case fertilizing = "ដាក់ជី"     // Fertilizing
    case harvesting = "ប្រមូលផល"   // Harvesting
    case pesticide = "បាញ់ថ្នាំ"    // Pesticide
    case other = "ផ្សេងៗ"           // Other
}

@Model
class FarmActivity {
    var title: String
    var activityType: String
    var date: Date
    var notes: String
    var isCompleted: Bool
    var reminderEnabled: Bool
    
    init(title: String, activityType: String, date: Date, notes: String = "", isCompleted: Bool = false, reminderEnabled: Bool = true) {
        self.title = title
        self.activityType = activityType
        self.date = date
        self.notes = notes
        self.isCompleted = isCompleted
        self.reminderEnabled = reminderEnabled
    }
}
```

### 1.3.3 Pest Model (for Pest Guide)
```swift
// Models/Pest.swift
import Foundation
import SwiftData

enum PestType: String, CaseIterable {
    case insect = "សត្វល្អិត"      // Insect
    case fungal = "ផ្សិត"           // Fungal
    case bacterial = "បាក់តេរី"     // Bacterial
    case viral = "មេរោគ"            // Viral
}

@Model
class Pest {
    var name: String
    var pestType: String
    var symptoms: String
    var treatment: String
    var prevention: String
    var imageName: String?
    var isFavorite: Bool
    
    init(name: String, pestType: String, symptoms: String, treatment: String, prevention: String = "", imageName: String? = nil, isFavorite: Bool = false) {
        self.name = name
        self.pestType = pestType
        self.symptoms = symptoms
        self.treatment = treatment
        self.prevention = prevention
        self.imageName = imageName
        self.isFavorite = isFavorite
    }
}
```

### 1.3.4 JournalEntry Model (for Daily Journal)
```swift
// Models/JournalEntry.swift
import Foundation
import SwiftData

enum WeatherType: String, CaseIterable {
    case sunny = "ក្តៅហាប"      // Sunny
    case rainy = "ភ្លៀង"        // Rainy
    case cloudy = "ពពក"         // Cloudy
    case windy = "ខ្យល់"        // Windy
}

@Model
class JournalEntry {
    var date: Date
    var content: String
    var weather: String
    var photoData: Data?  // Store image as Data
    var location: String?
    
    init(date: Date = Date(), content: String, weather: String = "sunny", photoData: Data? = nil, location: String? = nil) {
        self.date = date
        self.content = content
        self.weather = weather
        self.photoData = photoData
        self.location = location
    }
}
```

**Live Demo:** Create all four model files and explain each property.

---

## 📚 Lesson 1.4: Building FarmViewModel & MainTabView (45 minutes)

### 1.4.1 FarmViewModel (Central ViewModel)
```swift
// ViewModels/FarmViewModel.swift
import Foundation
import SwiftUI
import SwiftData

@Observable
class FarmViewModel {
    // MARK: - Properties
    var selectedTab = 0
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Sample Data for Preview
    static let preview: FarmViewModel = {
        let vm = FarmViewModel()
        // We'll add sample data next week with SwiftData
        return vm
    }()
    
    // MARK: - Helper Methods
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "៛"  // Riel symbol
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "៛0"
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "km-KH")  // Khmer locale
        return formatter.string(from: date)
    }
}
```

### 1.4.2 MainTabView (Root View)
```swift
// Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @State private var viewModel = FarmViewModel()
    
    var body: some View {
        TabView(selection: Bindable(viewModel).selectedTab) {
            FinanceTabView()
                .tabItem {
                    Label("ហិរញ្ញវត្ថុ", systemImage: "dollarsign.circle")
                }
                .tag(0)
            
            CalendarTabView()
                .tabItem {
                    Label("ប្រតិទិន", systemImage: "calendar")
                }
                .tag(1)
            
            PestGuideTabView()
                .tabItem {
                    Label("សត្វល្អិត", systemImage: "bug")
                }
                .tag(2)
            
            JournalTabView()
                .tabItem {
                    Label("កំណត់ហេតុ", systemImage: "book")
                }
                .tag(3)
        }
        .environment(viewModel)  // Pass ViewModel to all child views
    }
}

// Placeholder Views for each tab
struct FinanceTabView: View {
    @Environment(FarmViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            List {
                Text("Finance Tab - Coming Soon")
                Text("Total: \(viewModel.formatCurrency(0))")
            }
            .navigationTitle("កំណត់ត្រាចំណាយចំណូល")
        }
    }
}

struct CalendarTabView: View {
    var body: some View {
        NavigationStack {
            Text("Calendar Tab - Coming Soon")
                .navigationTitle("ប្រតិទិនដាំដំណាំ")
        }
    }
}

struct PestGuideTabView: View {
    var body: some View {
        NavigationStack {
            Text("Pest Guide Tab - Coming Soon")
                .navigationTitle("មគ្គុទេសក៍សត្វល្អិត")
        }
    }
}

struct JournalTabView: View {
    var body: some View {
        NavigationStack {
            Text("Journal Tab - Coming Soon")
                .navigationTitle("កំណត់ហេតុប្រចាំថ្ងៃ")
        }
    }
}
```

**Live Demo:** Build the MainTabView with all four tabs and run the app.

---

## 📚 Lesson 1.5: Khmer Localization & Constants (Remaining time)

### 1.5.1 Constants File
```swift
// Utilities/Constants.swift
import Foundation
import SwiftUI

struct AppColors {
    static let primary = Color("PrimaryGreen")
    static let expense = Color.red
    static let income = Color.green
    static let background = Color(.systemBackground)
}

struct AppStrings {
    // Tab titles
    static let financeTab = "ហិរញ្ញវត្ថុ"
    static let calendarTab = "ប្រតិទិន"
    static let pestTab = "សត្វល្អិត"
    static let journalTab = "កំណត់ហេតុ"
    
    // Common buttons
    static let save = "រក្សាទុក"
    static let cancel = "បោះបង់"
    static let delete = "លុប"
    static let edit = "កែប្រែ"
    static let add = "បន្ថែម"
}
```

### 1.5.2 Date Extension for Khmer
```swift
// Utilities/Extensions/Date+Khmer.swift
import Foundation

extension Date {
    func khmerFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "km-KH")
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }
}
```

---

## 🏠 Week 1 Mini-Project Assignment

### Task: Create the Foundation of Smart Farmer Assistant

**Requirements:**

1. **Project Structure (30%)**
   - Create all folders as shown in lesson
   - Verify project runs without errors

2. **Data Models (30%)**
   - Implement all 4 model classes exactly as shown
   - Add at least 2 enum cases to each category

3. **ViewModel & MainTabView (30%)**
   - Implement FarmViewModel with @Observable
   - Create MainTabView with all 4 tabs
   - Pass ViewModel using `.environment()`

4. **Khmer Language Support (10%)**
   - Add formatCurrency with Riel symbol (៛)
   - Ensure tab titles are in Khmer

**Bonus Challenge (Optional):**
- Add a 5th "Dashboard" tab that shows summary
- Implement a simple animation when switching tabs

**Submission Checklist:**
- [ ] Project builds successfully
- [ ] 4 model files exist with all properties
- [ ] FarmViewModel uses @Observable
- [ ] MainTabView shows 4 tabs with Khmer titles
- [ ] Code is properly formatted and commented

---


