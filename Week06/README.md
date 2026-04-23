# Week 6 : Pest & Disease Guide Module (Project 2)
## PestGuideTabView
## Topic: Building an offline reference library

---

**Learning Objectives**

By the end of this week, students will be able to:
- Model a `Pest` entity in Core Data (name, symptoms, treatment, imageName)
- Ship a JSON file inside the app bundle and load it into Core Data on first launch
- Build a **custom** search bar (iOS 13+ — no `.searchable`)
- Make list rows expand and collapse using `@State` (no `DisclosureGroup`)
- Design an **offline-first** feature — no network, no loading spinners, no empty states after the first launch

---

## ⚠️ iOS 13+ API Rules (Quick Reference)

| Feature | ❌ iOS 15+ Only | ✅ iOS 13+ Correct |
|---|---|---|
| List search | `.searchable(text: $query)` | Custom `SearchBar` on top of `List` |
| Disclosure | `DisclosureGroup` | `@State isExpanded` + chevron rotation |
| AsyncImage | `AsyncImage(url:)` | Bundled assets + `Image(named:)` |
| Navigation | `NavigationStack` | `NavigationView` |

> This course sticks with `NavigationView` for device compatibility. Everything
> you write this week runs on iOS 13 and later.

---

**Lesson Breakdown:**

| Lesson | Topic |
|--------|-------|
| 6.1 | Modelling the Pest entity in Core Data |
| 6.2 | Shipping `pests.json` and preloading on first launch |
| 6.3 | Building a custom iOS 13+ search bar |
| 6.4 | Expandable sections with `@State` |
| 6.5 | Putting it together — `PestGuideTabView` |

---

## 🗂 Folder Structure

The module follows the same shape as `Finance/` and `CalendarReminders/`:

```
SmartFarmerAssistantFinish/
└── PestDisease/
    ├── Models/
    │   ├── Pest+CoreDataClass.swift
    │   ├── Pest+CoreDataProperties.swift
    │   └── PestDTO.swift              ← Codable mirror for JSON
    ├── ViewModels/
    │   └── PestGuideViewModel.swift    ← search text + filter()
    ├── Services/
    │   └── PestDataLoader.swift        ← JSON → Core Data preload
    ├── Views/
    │   ├── PestGuideTabView.swift      ← root (List + SearchBar)
    │   ├── PestRowView.swift
    │   ├── PestDetailView.swift        ← expandable sections
    │   ├── SearchBar.swift             ← iOS 13+ custom bar
    │   └── ExpandableSection.swift     ← reusable disclosure
    └── Resources/
        └── pests.json                  ← bundled reference data
```

| Layer | Responsibility |
|---|---|
| **Models** | Core Data entity + a Codable DTO that matches the JSON shape |
| **Services** | Side-effects — in this module, reading the bundle and writing to Core Data |
| **ViewModels** | UI state that outlives a single view (`searchText` + filter logic) |
| **Views** | SwiftUI views only — no Core Data writes, no file I/O |
| **Resources** | The JSON file shipped with the app |

---

## 🏛 Architecture

```
┌───────────────────────────── App launch ────────────────────────────┐
│  SmartFarmerAssistantFinishApp.init()                               │
│      └─► PestDataLoader.preloadIfNeeded(context:)                   │
│              ├─ UserDefaults flag set?  →  skip                     │
│              └─ else: decode pests.json → insert Pest objects →     │
│                       save context → set flag                       │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌────────────────────────── User runs the app ────────────────────────┐
│  PestGuideTabView                                                   │
│      ├─ @FetchRequest<Pest>   (alphabetical)                        │
│      ├─ @StateObject vm = PestGuideViewModel()                      │
│      ├─ SearchBar(text: $vm.searchText)                             │
│      └─ List { ForEach(vm.filter(pests)) { PestRowView } }          │
│             └─► NavigationLink → PestDetailView                     │
│                       └─ ExpandableSection ×3                       │
│                            (Symptoms / Treatment / Prevention)      │
└─────────────────────────────────────────────────────────────────────┘
```

**Key idea:** The view layer never reads JSON. JSON → Core Data happens once,
then the rest of the app treats pests exactly like any other Core Data model.

---

## 📚 Lesson 6.1: Modelling the Pest Entity (30 minutes)

Open `SmartFarmerAssistantFinish.xcdatamodeld` and confirm the **Pest** entity
has these attributes:

| Attribute | Type | Notes |
|-----------|------|-------|
| `id` | UUID | Stable identifier — also doubles as the row key |
| `name` | String | The pest / disease name, shown in the list and detail title |
| `symptoms` | String | What the farmer will see on the plant |
| `treatment` | String | What to do once the problem is confirmed |
| `imageName` | String | Asset-catalog name, optional (falls back to an SF Symbol) |
| `pestType` | String | Optional label — "Disease (fungus)", "Pest (insect)", … |
| `prevention` | String | Optional — rendered as a collapsible section |
| `isFavorite` | Bool | Toggled by the star button in the detail screen |

> In the Data Model Inspector, set **Codegen = Manual/None** so Xcode doesn't
> auto-generate a duplicate class. We provide our own files:

```swift
// PestDisease/Models/Pest+CoreDataClass.swift
import Foundation
import CoreData

@objc(Pest)
public class Pest: NSManagedObject {
    var displayName: String { name ?? "" }
    var hasImage: Bool { imageName.map { !$0.isEmpty } ?? false }
}
```

```swift
// PestDisease/Models/Pest+CoreDataProperties.swift
import Foundation
import CoreData

extension Pest {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pest> {
        NSFetchRequest<Pest>(entityName: "Pest")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var symptoms: String?
    @NSManaged public var treatment: String?
    @NSManaged public var imageName: String?
    @NSManaged public var pestType: String?
    @NSManaged public var prevention: String?
    @NSManaged public var isFavorite: Bool
}

extension Pest: Identifiable {}
```

> **Why split the class and the properties?**
> Same convention used by `Transaction` (Week 4) and `FarmActivity` (Week 5).
> Xcode used to regenerate `+CoreDataProperties.swift` on every schema change;
> keeping properties in their own file meant you didn't lose your custom logic
> in the class file.

---

## 📚 Lesson 6.2: JSON Preload on First Launch (60 minutes)

**Goal:** Ship a ready-to-read library so the user never sees an empty app.

**Where the data lives:**

```
PestDisease/Resources/pests.json   ← committed to the repo
            │  (Xcode bundles it into the .app)
            ▼
Bundle.main.url(forResource: "pests", withExtension: "json")
```

**The JSON shape (matches `PestDTO`):**

```json
{
  "version": 1,
  "pests": [
    {
      "id": "11111111-1111-1111-1111-111111111111",
      "name": "Rice blast",
      "pestType": "Disease (fungus)",
      "symptoms": "Diamond-shaped brown spots with gray centers …",
      "treatment": "Apply fungicides labeled for rice blast …",
      "prevention": "Use resistant varieties when available …",
      "imageName": "Rice blast"
    }
  ]
}
```

**The DTO:**

```swift
// PestDisease/Models/PestDTO.swift
struct PestBundle: Codable {
    let version: Int
    let pests: [PestDTO]
}

struct PestDTO: Codable {
    let id: String
    let name: String
    let pestType: String?
    let symptoms: String
    let treatment: String
    let prevention: String?
    let imageName: String?
}
```

> **Why a DTO?** Core Data's `NSManagedObject` is not `Codable` out of the box,
> and even if we added conformance it ties the file format to the live schema.
> A DTO is a plain Swift struct — the JSON can evolve without forcing a
> Core Data migration.

**The loader:**

```swift
// PestDisease/Services/PestDataLoader.swift
enum PestDataLoader {
    private static let preloadKey = "kPestsPreloaded"

    static func preloadIfNeeded(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        guard !UserDefaults.standard.bool(forKey: preloadKey) else { return }

        do {
            let dtos = try loadBundledDTOs()
            try insert(dtos, into: context)
            UserDefaults.standard.set(true, forKey: preloadKey)
        } catch {
            print("PestDataLoader: preload failed — \(error)")
        }
    }

    private static func loadBundledDTOs() throws -> [PestDTO] {
        guard let url = Bundle.main.url(forResource: "pests", withExtension: "json") else {
            throw NSError(domain: "PestDataLoader", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "pests.json not found"])
        }
        let data = try Data(contentsOf: url)
        let bundle = try JSONDecoder().decode(PestBundle.self, from: data)
        return bundle.pests
    }

    private static func insert(_ dtos: [PestDTO], into context: NSManagedObjectContext) throws {
        for dto in dtos {
            let pest = Pest(context: context)
            pest.id         = UUID(uuidString: dto.id) ?? UUID()
            pest.name       = dto.name
            pest.symptoms   = dto.symptoms
            pest.treatment  = dto.treatment
            pest.imageName  = dto.imageName
            pest.pestType   = dto.pestType
            pest.prevention = dto.prevention
            pest.isFavorite = false
        }
        if context.hasChanges { try context.save() }
    }
}
```

**Call it from the App struct — exactly once at startup:**

```swift
@main
struct SmartFarmerAssistantFinishApp: App {
    let context = CoreDataManager.shared.context
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        PestDataLoader.preloadIfNeeded(context: CoreDataManager.shared.context)
    }

    var body: some Scene { … }
}
```

**Preload flow (diagram):**

```
 App launches
      │
      ▼
 preloadIfNeeded()
      │
      ▼
 UserDefaults["kPestsPreloaded"] == true ? ──► yes ──► return (no work)
      │ no
      ▼
 Bundle.main.url("pests.json") ──► Data
      │
      ▼
 JSONDecoder().decode(PestBundle.self)
      │
      ▼
 For each PestDTO:
   Pest(context:)  ←─  copy fields
      │
      ▼
 context.save()
      │
      ▼
 UserDefaults["kPestsPreloaded"] = true
      │
      ▼
 Next launch: flag is true ──► skip everything above
```

| Design choice | Why |
|---|---|
| `UserDefaults` flag | Cheap, synchronous, survives re-installs inside the same container |
| No flag on failure | If decoding/insert fails we retry next launch — better than a half-loaded store |
| `enum` with static methods | No instance state — prevents accidental double-loading |
| DTO + `Codable` | JSON format decoupled from Core Data schema |

---

## 📚 Lesson 6.3: Custom Search Bar (iOS 13+) (45 minutes)

SwiftUI's `.searchable` modifier is iOS 15+. For iOS 13+ we build our own — a
`TextField` wrapped in a rounded container plus a dynamic "Cancel" button.

```swift
// PestDisease/Views/SearchBar.swift
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "ស្វែងរក…"

    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) { isEditing = editing }
                })
                .autocapitalization(.none)
                .disableAutocorrection(true)

                if !text.isEmpty {
                    Button { text = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if isEditing {
                Button("បោះបង់") {
                    text = ""
                    isEditing = false
                    hideKeyboard()
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
```

> **Design detail:** the `Cancel` button appears only while the field has
> focus. We track focus with `@State private var isEditing` driven by
> `onEditingChanged`, because `@FocusState` is iOS 15+.

**Filtering lives in the ViewModel — not the view:**

```swift
// PestDisease/ViewModels/PestGuideViewModel.swift
class PestGuideViewModel: ObservableObject {
    @Published var searchText: String = ""

    func filter(_ pests: [Pest]) -> [Pest] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return pests }
        return pests.filter { pest in
            contains(pest.name, query) ||
            contains(pest.symptoms, query) ||
            contains(pest.treatment, query) ||
            contains(pest.pestType, query)
        }
    }

    private func contains(_ h: String?, _ n: String) -> Bool {
        h?.localizedCaseInsensitiveContains(n) ?? false
    }
}
```

| Why the ViewModel? |
|---|
| Search logic is testable in isolation |
| The view stays declarative — it only renders what the VM returns |
| Other views (e.g. a future "Related pests" panel) can reuse `filter(_:)` |

---

## 📚 Lesson 6.4: Expandable Sections with `@State` (30 minutes)

Instead of `DisclosureGroup` (available but inconsistent on iOS 13), we build
a small reusable section with local state:

```swift
// PestDisease/Views/ExpandableSection.swift
struct ExpandableSection<Content: View>: View {
    let title: String
    var icon: String? = nil
    var initiallyExpanded: Bool = true
    @ViewBuilder let content: () -> Content

    @State private var isExpanded: Bool

    init(title: String,
         icon: String? = nil,
         initiallyExpanded: Bool = true,
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.initiallyExpanded = initiallyExpanded
        self.content = content
        _isExpanded = State(initialValue: initiallyExpanded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon)
                            .foregroundColor(.green)
                            .frame(width: 20)
                    }
                    Text(title).font(.headline).foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical, 10)

            if isExpanded {
                content()
                    .padding(.bottom, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider()
        }
    }
}
```

Use it in the detail screen:

```swift
ExpandableSection(title: "Symptoms", icon: "stethoscope") {
    Text(pest.symptoms ?? "—")
}
ExpandableSection(title: "Treatment", icon: "cross.case") {
    Text(pest.treatment ?? "—")
}
ExpandableSection(title: "Prevention",
                  icon: "shield.lefthalf.filled",
                  initiallyExpanded: false) {
    Text(pest.prevention ?? "—")
}
```

> **Each section owns its own `@State`.** Opening "Treatment" does not close
> "Symptoms" — a common mistake when learners try to share one Bool across
> all sections.

---

## 📚 Lesson 6.5: Putting It Together — `PestGuideTabView` (30 minutes)

```swift
// PestDisease/Views/PestGuideTabView.swift
struct PestGuideTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Pest.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pest.name, ascending: true)]
    ) private var pests: FetchedResults<Pest>

    @StateObject private var viewModel = PestGuideViewModel()

    private var displayedPests: [Pest] { viewModel.filter(Array(pests)) }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText,
                          placeholder: "ស្វែងរកឈ្មោះ រោគសញ្ញា …")

                if displayedPests.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(displayedPests, id: \.self) { pest in
                            NavigationLink(destination: PestDetailView(pest: pest)) {
                                PestRowView(pest: pest)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("មគ្គុទ្ទេសសត្វល្អិត")
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text(viewModel.searchText.isEmpty
                 ? "មិនមានទិន្នន័យ — ទាញពី pests.json"
                 : "រកមិនឃើញលទ្ធផលសម្រាប់ \"\(viewModel.searchText)\"")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}
```

**Reading the flow, top to bottom:**

1. `@FetchRequest` watches the `Pest` table. Adding or editing pests elsewhere
   automatically re-renders this view.
2. The view model exposes `searchText` (a `@Published`) and a pure `filter(_:)`.
3. `displayedPests` is computed on every render — cheap for a list of this
   size. For larger libraries, move it into the view model as a
   `@Published` derived value.
4. The empty state distinguishes "no data at all" from "no search results".

---

## 🎨 UI / UX Suggestions

| Element | Suggestion |
|---|---|
| Tab icon | `ladybug` SF Symbol (already wired in `MainTabView`) |
| List rows | 44pt thumbnail (asset or `ladybug.fill` fallback), bold title, gray subtitle |
| Search bar | Rounded `systemGray6` pill at the top — `.searchable` look without the dependency |
| Detail header | Full-width image if asset exists, otherwise a pastel-green placeholder with an SF Symbol |
| Sections | Icon + title row, chevron rotates 90° on open — same convention as Settings.app |
| Favorites | Yellow star toolbar button in the detail nav bar |
| Typography | `.title2.bold()` for the pest name, `.subheadline` for the type label |

**Suggested SF Symbols:**

| Purpose | Symbol |
|---|---|
| Tab | `ladybug` / `ladybug.fill` |
| Search | `magnifyingglass` |
| Clear search | `xmark.circle.fill` |
| Symptoms | `stethoscope` |
| Treatment | `cross.case` |
| Prevention | `shield.lefthalf.filled` |
| Favorite | `star` / `star.fill` |
| Empty state | `magnifyingglass` |

---

## 🌐 Offline-First — What Does It Really Mean?

| Need | Weak approach | Strong approach |
|---|---|---|
| First launch | Show a spinner while pulling JSON from the server | Read a bundled JSON file — zero latency |
| Updates | Poll an API | Ship a new JSON with the next app release |
| Airplane mode | Blocked screen | Full app works exactly the same |
| Privacy | Every read leaks to a server | No network traffic at all |

> **Rule of thumb:** if the user has to wait for the network on first tap,
> it isn't offline-first.

---

### Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Forgetting to add `pests.json` to the app target | `Bundle.main.url(...)` returns `nil` | Drag into Xcode and tick the app target in the file inspector |
| Not setting Codegen to "Manual/None" | Duplicate `Pest` class error | Data Model Inspector → Codegen → Manual/None |
| Calling `preloadIfNeeded` from `onAppear` | Seeds again every time the view appears | Call it **once** from `App.init()` |
| Sharing a single `isExpanded` across sections | All sections open/close together | Each `ExpandableSection` owns its own `@State` |
| Filtering inside `body` with a `FetchRequest` predicate parameter | Re-creates the fetch on every keystroke | Filter in Swift on the already-fetched array |
| Storing search text in `@State` in the root view | Lost on tab switch, can't be reused | Keep it in the `@StateObject` ViewModel |
| Missing fallback for `imageName` | Blank rows for pests without assets | Check `UIImage(named:)` and fall back to an SF Symbol |

---

*End of Week 6 Materials - Pest & Disease Guide Module*
