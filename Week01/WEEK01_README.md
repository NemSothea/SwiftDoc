# Week 01 — Project Setup & MVVM Architecture

![iOS](https://img.shields.io/badge/iOS-13%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green) ![Xcode](https://img.shields.io/badge/Xcode-15%2B-blue)

> **Project:** SmartFarmer Assistant — An agricultural management app for Cambodian farmers.

---

## 🎯 Learning Objectives

By the end of Week 01, students will be able to:
- Create a professional Xcode project with proper folder structure
- Explain and apply MVVM architecture
- Define all four CoreData models (`Transaction`, `FarmActivity`, `Pest`, `JournalEntry`)
- Build `FarmViewModel` using `ObservableObject` (iOS 13+)
- Build `MainTabView` with four tabs and pass ViewModel via `.environmentObject()`

---

## ⚡ Quick Reference

| File | Purpose |
|---|---|
| `App/SmartFarmerAssistantApp.swift` | Entry point `@main`, CoreData container |
| `Models/Transaction+CoreData.swift` | Finance transaction entity |
| `Models/FarmActivity+CoreData.swift` | Calendar activity entity |
| `Models/Pest+CoreData.swift` | Pest/disease guide entity |
| `Models/JournalEntry+CoreData.swift` | Daily journal entity |
| `ViewModels/FarmViewModel.swift` | Central `ObservableObject` ViewModel |
| `Views/MainTabView.swift` | Root 4-tab navigation |
| `Utilities/CoreDataManager.swift` | Singleton CoreData stack |
| `Utilities/Constants.swift` | App-wide strings and colors |

---

## ⚠️ iOS 13+ Rules

This course targets **iOS 13+**. Always use:

| ✅ iOS 13+ (Correct) | ❌ iOS 17+ Only |
|---|---|
| `class VM: ObservableObject` | `@Observable class VM` |
| `@StateObject var vm: VM` | `@State var vm: VM` |
| `@EnvironmentObject var vm: VM` | `@Environment(VM.self)` |
| `.environmentObject(vm)` | `.environment(vm)` |
| `NavigationView {}` | `NavigationStack {}` |

---

## 📚 Lesson 1.1 — MVVM Architecture (45 min)

**Model → ViewModel → View**

```
Model               ViewModel              View
─────────           ─────────────          ──────────────
Transaction         FarmViewModel          FinanceTabView
FarmActivity        ObservableObject       CalendarTabView
Pest                @Published state       PestGuideTabView
JournalEntry        Business logic         JournalTabView
```

- **Model** — Pure data structs/classes. No UI code.
- **ViewModel** — Owns state, performs CRUD, formats data for views.
- **View** — SwiftUI `struct`. Reads ViewModel via `@EnvironmentObject`. Never writes to CoreData directly.

---

## 📚 Lesson 1.2 — Xcode Project Setup (30 min)

1. **File → New → Project → iOS → App**
2. Configure:
   - Product Name: `SmartFarmerAssistant`
   - Interface: `SwiftUI` · Language: `Swift`
   - **Minimum Deployments: iOS 13.0**
   - Uncheck "Use Core Data" (we set up manually)
3. Create folder groups in the Project Navigator:

```
SmartFarmerAssistant/
├── App/
│   └── SmartFarmerAssistantApp.swift
├── Models/
│   ├── Transaction+CoreDataClass.swift
│   ├── Transaction+CoreDataProperties.swift
│   ├── FarmActivity+CoreData*.swift
│   ├── Pest+CoreData*.swift
│   └── JournalEntry+CoreData*.swift
├── ViewModels/
│   └── FarmViewModel.swift
├── Views/
│   ├── MainTabView.swift
│   ├── Finance/
│   ├── Calendar/
│   ├── PestGuide/
│   └── Journal/
├── Utilities/
│   ├── CoreDataManager.swift
│   └── Constants.swift
└── Resources/
    └── Assets.xcassets
```

---

## 📚 Lesson 1.3 — CoreData Models (45 min)

### App Entry Point

```swift
// App/SmartFarmerAssistantApp.swift
@main
struct SmartFarmerAssistantApp: App {
    let context = CoreDataManager.shared.context

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, context)
        }
    }
}
```

### Transaction (Finance)

```swift
// Models/Transaction+CoreDataProperties.swift
extension Transaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    @NSManaged public var amount:   Double
    @NSManaged public var date:     Date?
    @NSManaged public var note:     String?
    @NSManaged public var type:     String?   // "expense" | "income"
    @NSManaged public var category: String?
    @NSManaged public var id:       UUID?
}
extension Transaction: Identifiable {}

enum ExpenseCategory: String, CaseIterable {
    case seeds = "គ្រាប់ពូជ", fertilizer = "ជី",
         labor = "កម្លាំងពលកម្ម", tools = "ឧបករណ៍", other = "ផ្សេងៗ"
}
enum IncomeCategory: String, CaseIterable {
    case vegetable = "បន្លែ", fruit = "ផ្លែឈើ",
         grain = "ស្រូវ-ដំណាំ", livestock = "សត្វ", other = "ផ្សេងៗ"
}
```

### FarmActivity (Calendar)

```swift
extension FarmActivity {
    @NSManaged public var id:              UUID?
    @NSManaged public var title:           String?
    @NSManaged public var activityType:    String?
    @NSManaged public var date:            Date?
    @NSManaged public var notes:           String?
    @NSManaged public var isCompleted:     Bool
    @NSManaged public var reminderEnabled: Bool
}

enum ActivityType: String, CaseIterable {
    case planting = "ដាំ", watering = "ស្រោចទឹក",
         fertilizing = "ដាក់ជី", harvesting = "ប្រមូលផល",
         pesticide = "បាញ់ថ្នាំ", other = "ផ្សេងៗ"
}
```

### Pest & JournalEntry

```swift
extension Pest {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var pestType: String?
    @NSManaged public var symptoms: String?
    @NSManaged public var treatment: String?
    @NSManaged public var prevention: String?
    @NSManaged public var imageName: String?
    @NSManaged public var isFavorite: Bool
}

extension JournalEntry {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var content: String?
    @NSManaged public var weather: String?
    @NSManaged public var photoData: Data?
    @NSManaged public var location: String?
}
```

---

## 📚 Lesson 1.4 — FarmViewModel (30 min)

```swift
// ViewModels/FarmViewModel.swift
import Foundation
import CoreData

// ✅ ObservableObject for iOS 13+  ❌ Do NOT use @Observable (iOS 17+ only)
class FarmViewModel: ObservableObject {

    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    // MARK: - Formatters
    func formatCurrency(_ amount: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_US")
        return f.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "km-KH")
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
```

---

## 📚 Lesson 1.5 — MainTabView & Constants (30 min)

```swift
// Views/MainTabView.swift
struct MainTabView: View {
    // ✅ @StateObject — this view OWNS the ViewModel
    @StateObject private var viewModel: FarmViewModel
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var viewContext

    init() {
        _viewModel = StateObject(wrappedValue:
            FarmViewModel(context: CoreDataManager.shared.context))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            FinanceTabView()
                .tabItem { Label("ហិរញ្ញវត្ថុ", systemImage: "dollarsign.circle") }
                .tag(0)
                .environment(\.managedObjectContext, viewContext)
            // ... Calendar, PestGuide, Journal tabs
        }
        // ✅ Pass ViewModel to ALL child views
        .environmentObject(viewModel)
    }
}
```

```swift
// Utilities/Constants.swift
struct AppStrings {
    static let financeTab  = "ហិរញ្ញវត្ថុ"
    static let calendarTab = "ប្រតិទិន"
    static let pestTab     = "សត្វល្អិត"
    static let journalTab  = "កំណត់ហេតុ"
    static let save   = "រក្សាទុក"
    static let cancel = "បោះបង់"
    static let delete = "លុប"
    static let add    = "បន្ថែម"
}
```

---

## 🏠 Mini-Project Assignment

| Requirement | Weight |
|---|---|
| All folder groups created, project builds | 25% |
| 4 CoreData model files with all properties | 30% |
| `FarmViewModel` uses `ObservableObject` | 25% |
| `MainTabView` with 4 Khmer-titled tabs + `.environmentObject()` | 20% |

**Bonus:** Add a 5th Dashboard tab showing a welcome message.

### Submission Checklist
- [ ] Project builds with no errors
- [ ] 4 `@NSManaged` model files exist
- [ ] `FarmViewModel: ObservableObject` (not `@Observable`)
- [ ] `MainTabView` shows 4 tabs with Khmer titles
- [ ] `.environmentObject(viewModel)` passed from `MainTabView`
- [ ] `CoreDataManager.shared` used in `App` entry point

---

*End of Week 01 — Ready for CoreData CRUD in Week 02 →*
