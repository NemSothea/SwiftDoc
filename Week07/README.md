# Week 7 : Daily Journal Module (Project 4)
## JournalTabView
## Topic: Digital notebook with rich text and weather

---

**Learning Objectives**

By the end of this week, students will be able to:
- Model a `JournalEntry` entity in Core Data (date, content, weather, photos, title)
- Build a **reverse-chronological** timeline UI, grouped by day
- Implement a four-option weather picker using SF Symbols
- Bridge `UIImagePickerController` into SwiftUI with `UIViewControllerRepresentable`
- Build a **custom** search bar + weather filter chip row (iOS 13+ — no `.searchable`)

---

## ⚠️ iOS 13+ API Rules (Quick Reference)

| Feature | ❌ iOS 15+ Only | ✅ iOS 13+ Correct |
|---|---|---|
| List search | `.searchable(text: $query)` | Custom `SearchBar` on top of `List` |
| Photo picker | `PhotosPicker` (iOS 16+) | `UIImagePickerController` + `UIViewControllerRepresentable` |
| Navigation | `NavigationStack` | `NavigationView` |
| View model | `@Observable class VM` | `class VM: ObservableObject` |
| State VM | `@State var vm: VM` | `@StateObject var vm: VM` |
| Image from URL | `AsyncImage(url:)` | Store `Data` in Core Data, render via `UIImage(data:)` |

> This course keeps the deployment target at iOS 13. Everything you write this
> week runs on iOS 13 and later — including the photo picker.

---

**Lesson Breakdown:**

| Lesson | Topic |
|--------|-------|
| 7.1 | Designing the `JournalEntry` Core Data entity |
| 7.2 | Building the timeline list (newest first) |
| 7.3 | Weather selection UI (Sunny / Rainy / Cloudy / Windy) |
| 7.4 | Photo picker — `UIImagePickerController` + `UIViewControllerRepresentable` |
| 7.5 | Search & filter using a custom `TextField` (no `.searchable`) |

---

## 🗂 Folder Structure

The module follows the same shape as `Finance/`, `CalendarReminders/`, and `PestDisease/`:

```
SmartFarmerAssistantFinish/
└── Journal/
    ├── Models/
    │   ├── JournalEntry+CoreDataClass.swift
    │   ├── JournalEntry+CoreDataProperties.swift
    │   └── Weather.swift                      ← enum + SF Symbol + tint
    ├── ViewModels/
    │   └── JournalViewModel.swift             ← searchText, weatherFilter, filter(_:)
    ├── Services/
    │   └── JournalPhotoStore.swift            ← UIImage ↔ [Data] helpers
    ├── Views/
    │   ├── JournalTabView.swift               ← root (SearchBar + chips + List)
    │   ├── JournalRowView.swift               ← title, snippet, weather, photo count
    │   ├── JournalDetailView.swift            ← weather badge + TextEditor + gallery
    │   ├── AddJournalEntryView.swift          ← create sheet
    │   ├── EditJournalEntryView.swift         ← edit sheet
    │   ├── WeatherPickerView.swift            ← 4 circular weather buttons
    │   ├── PhotoPicker.swift                  ← UIKit bridge for images
    │   └── PhotoGalleryView.swift             ← horizontal thumbnail strip
    └── Resources/
        └── (empty — entries are user-authored, no seed JSON)
```

> **Reused from Week 6:** `SearchBar` and `ExpandableSection` already live inside
> `PestDisease/Views/`. Because this is a single Xcode target, Swift types are
> visible across modules — we use them directly rather than duplicating files.

| Layer | Responsibility |
|---|---|
| **Models** | Core Data class + the `Weather` enum |
| **ViewModels** | UI state that outlives a view (`searchText`, `weatherFilter`) + pure filter logic |
| **Services** | Side-effect helpers — here, encode/decode `UIImage` as JPEG `Data` |
| **Views** | SwiftUI only — no Core Data writes except inside the Add/Edit sheets' `save()` |
| **Resources** | Empty for this module — journal entries are authored by the user |

---

## 🏛 Architecture

```
┌───────────────────────────── App launch ────────────────────────────┐
│  SmartFarmerAssistantFinishApp.init()                               │
│      └─► CoreDataManager.shared.context  (shared across modules)    │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌────────────────────────── User opens the Journal tab ───────────────┐
│  JournalTabView                                                     │
│      ├─ @FetchRequest<JournalEntry>   (date, descending)            │
│      ├─ @StateObject vm = JournalViewModel()                        │
│      ├─ SearchBar(text: $vm.searchText)                             │
│      ├─ WeatherChipsRow(selection: $vm.weatherFilter)               │
│      └─ List {                                                      │
│           Section(day) {                                            │
│             ForEach(vm.filter(entries)) { JournalRowView }          │
│               └─► NavigationLink → JournalDetailView                │
│                        ├─ weatherBadge                              │
│                        ├─ TextEditor(entry.content)                 │
│                        ├─ ExpandableSection("Photos")               │
│                        │       └─ PhotoGalleryView(images)          │
│                        └─ ExpandableSection("Metadata")             │
│             }                                                       │
│           }                                                         │
│         }                                                           │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────── User taps "+"  ─────────────────────────────┐
│  AddJournalEntryView (sheet)                                        │
│      ├─ TextField("Title?")                                         │
│      ├─ WeatherPickerView                                           │
│      ├─ TextEditor("Content")                                       │
│      └─ "Add photo" → PhotoPicker (sheet)                           │
│                         └─ UIImagePickerController                  │
│                               └─ didFinishPicking → UIImage         │
│                                      └─ JPEG Data → [Data]          │
└─────────────────────────────────────────────────────────────────────┘
```

**Key idea:** the view layer never builds a `UIImage` from raw bytes in the
timeline. Images are lazy — they're decoded only when a detail view (or
gallery) asks for them.

---

## 📚 Lesson 7.1: Designing the `JournalEntry` Entity (30 minutes)

**Goal:** add a single new entity to the shared `SmartFarmerAssistantFinish.xcdatamodeld`
with seven attributes — same pattern students used for `Pest` and `FarmActivity`.

Open the data model and add:

| Attribute | Type | Notes |
|-----------|------|-------|
| `id` | UUID | Stable identifier |
| `date` | Date | Timeline sort key — also groups rows by day |
| `title` | String? | Optional — falls back to the first line of `content` |
| `content` | String | Body text — edited in a `TextEditor` |
| `weather` | String | Raw value of the `Weather` enum (`sunny`, `rainy`, `cloudy`, `windy`) |
| `location` | String? | Optional — bonus field, not required by the spec |
| `photos` | Transformable | `[Data]` array of JPEGs — stored via `NSSecureUnarchiveFromData` |

> **Codegen = Manual/None.** In the Data Model Inspector, clear the
> *Codegen* drop-down. Xcode will stop auto-generating the class, which is
> what lets you hand-write `+CoreDataClass.swift` with computed helpers.

> **Why Transformable for `photos`?** Core Data has no first-class
> `[Data]` type. `Transformable` turns any `NSSecureCoding` value into a
> blob at save time. We set the *Transformer* to `NSSecureUnarchiveFromData`
> (Apple's built-in secure coder) and the *Custom Class* to `NSArray` — that
> lets an `NSArray` of `NSData` round-trip safely.

```swift
// Journal/Models/JournalEntry+CoreDataProperties.swift
extension JournalEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntry> {
        NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var weather: String?
    @NSManaged public var location: String?
    @NSManaged public var photos: NSObject?     // backed by an NSArray of Data
}

extension JournalEntry: Identifiable {}
```

```swift
// Journal/Models/JournalEntry+CoreDataClass.swift
@objc(JournalEntry)
public class JournalEntry: NSManagedObject {

    var weatherTag: Weather {
        Weather(rawValue: weather ?? "") ?? .sunny
    }

    var photoDatas: [Data] {
        (photos as? [Data]) ?? []
    }

    var displayTitle: String {
        if let title, !title.isEmpty { return title }
        let firstLine = (content ?? "")
            .split(whereSeparator: \.isNewline)
            .first
            .map(String.init) ?? ""
        return firstLine.isEmpty ? "(No title)" : firstLine
    }
}
```

| Design choice | Why |
|---|---|
| Separate `+CoreDataClass` and `+CoreDataProperties` | Same convention as `Pest` and `FarmActivity` — properties can be regenerated without losing `weatherTag` / `photoDatas` helpers |
| `weather` stored as `String`, not raw enum | Core Data can't persist Swift enums directly — the view maps through `Weather(rawValue:)` |
| `photos` as `[Data]` (JPEG) | Keeps the SQLite store self-contained — no sidecar files to clean up |
| `title` optional | Apple Notes works the same way: the first line IS the title until the user types one |

---

## 📚 Lesson 7.2: The Timeline List (60 minutes)

**Goal:** fetch every journal entry sorted newest-first, group them by day,
and render each day as its own `Section` with a formatted header.

```swift
// Journal/Views/JournalTabView.swift
@FetchRequest(
    entity: JournalEntry.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]
) private var entries: FetchedResults<JournalEntry>

@StateObject private var viewModel = JournalViewModel()

private var dayGroups: [(Date, [JournalEntry])] {
    viewModel.groupByDay(viewModel.filter(Array(entries)))
}
```

Grouping is a pure function in the view model — easy to test, easy to reuse:

```swift
// Journal/ViewModels/JournalViewModel.swift
func groupByDay(_ entries: [JournalEntry]) -> [(Date, [JournalEntry])] {
    let calendar = Calendar.current
    let groups = Dictionary(grouping: entries) { entry -> Date in
        calendar.startOfDay(for: entry.date ?? Date.distantPast)
    }
    return groups
        .map { ($0.key, $0.value.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }) }
        .sorted { $0.0 > $1.0 }
}
```

The `List` body wraps each group in a `Section`:

```swift
List {
    ForEach(dayGroups, id: \.0) { day, entriesInDay in
        Section(header: Text(sectionHeader(for: day))) {
            ForEach(entriesInDay, id: \.self) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    JournalRowView(entry: entry)
                }
            }
            .onDelete { indices in delete(indices, from: entriesInDay) }
        }
    }
}
.listStyle(PlainListStyle())
```

> **Why `ascending: false`?** A journal is read newest-first —
> today's entry should be on top of the list, not the bottom. A single
> wrong flag flips the whole user experience.

> **Why group in the view model, not the `@FetchRequest`?**
> `@FetchRequest` can sort but it can't group into `[(Date, [Entry])]`.
> Doing it in Swift keeps the fetch simple and the grouping testable.

| Design choice | Why |
|---|---|
| `Calendar.current.startOfDay(for:)` as the group key | Two entries at 08:00 and 22:00 on the same day end up in the same bucket — time doesn't leak into the grouping |
| `PlainListStyle` | Removes the inset gaps — section headers sit flush with rows, Apple Notes style |
| Delete on the displayed array, not the fetch results | Users delete what they see. The fetch re-runs automatically after `save()` |

---

## 📚 Lesson 7.3: Weather Selection UI (30 minutes)

**Goal:** build a four-button row for tagging an entry's weather — and teach the
`enum + rawValue + SF Symbol` pattern used for categorical data throughout the course.

```swift
// Journal/Models/Weather.swift
enum Weather: String, CaseIterable, Identifiable {
    case sunny, rainy, cloudy, windy

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .sunny:  return "sun.max.fill"
        case .rainy:  return "cloud.rain.fill"
        case .cloudy: return "cloud.fill"
        case .windy:  return "wind"
        }
    }

    var label: String {
        switch self {
        case .sunny:  return "ថ្ងៃល្អ"
        case .rainy:  return "ភ្លៀង"
        case .cloudy: return "មានពពក"
        case .windy:  return "មានខ្យល់"
        }
    }

    var tint: Color {
        switch self {
        case .sunny:  return .yellow
        case .rainy:  return .blue
        case .cloudy: return .gray
        case .windy:  return .teal
        }
    }
}
```

```swift
// Journal/Views/WeatherPickerView.swift
struct WeatherPickerView: View {
    @Binding var selection: Weather

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Weather.allCases) { weather in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selection = weather
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: weather.symbolName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(selection == weather ? .white : weather.tint)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle().fill(selection == weather
                                              ? weather.tint
                                              : Color(.systemGray6))
                            )
                        Text(weather.label).font(.caption)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
    }
}
```

> **Why store the `rawValue`, not the enum?** `@NSManaged` attributes can't
> be a Swift enum — Core Data stores a `String`. The computed
> `entry.weatherTag` is where we translate back. Keep the mapping in ONE
> place so the rest of the code never hand-rolls `"sunny"` literals.

| Design choice | Why |
|---|---|
| `CaseIterable` | Drives `ForEach(Weather.allCases)` — adding a fifth weather type is a one-line change |
| SF Symbols everywhere | Free, scaled for every device, tinted with `.foregroundColor` |
| Tints defined on the enum | Both the picker and the timeline row read `weather.tint` — one source of truth |

---

## 📚 Lesson 7.4: Photo Picker via UIKit Bridge (60 minutes)

**Goal:** teach `UIViewControllerRepresentable` — the official way to embed a
UIKit screen inside SwiftUI on iOS 13.

```swift
// Journal/Views/PhotoPicker.swift
struct PhotoPicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var onPick: (UIImage?) -> Void

    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoPicker
        init(parent: PhotoPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.onPick(info[.originalImage] as? UIImage)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onPick(nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
```

Use it from any SwiftUI view as a sheet:

```swift
.sheet(isPresented: $showingPicker) {
    PhotoPicker { image in
        if let image { pickedImages.append(image) }
    }
}
```

Images are JPEG-encoded before they land in Core Data:

```swift
// Journal/Services/JournalPhotoStore.swift
static func encode(_ image: UIImage, quality: CGFloat = 0.8) -> Data? {
    image.jpegData(compressionQuality: quality)
}

static func append(_ image: UIImage,
                   to entry: JournalEntry,
                   context: NSManagedObjectContext) {
    guard let data = encode(image) else { return }
    var list = entry.photoDatas
    list.append(data)
    entry.photos = list as NSArray
    try? context.save()
}
```

> **Why three methods on `UIViewControllerRepresentable`?** `makeUIViewController`
> creates the UIKit screen once; `updateUIViewController` re-syncs when SwiftUI
> state changes (nothing to do here); `makeCoordinator` hands SwiftUI an object
> that can be the UIKit delegate — SwiftUI structs can't be delegates.

> **Why JPEG at 0.8?** A 12MP camera photo is ~24 MB as raw `UIImage` bytes,
> ~3 MB as JPEG at 0.8, and visually indistinguishable. Smaller Core Data
> store, smaller backups, faster fetches.

| Design choice | Why |
|---|---|
| UIKit bridge instead of `PhotosPicker` | `PhotosPicker` is iOS 16+; we ship on iOS 13+ |
| Coordinator owns the delegate methods | SwiftUI structs are value types and can't conform to `NSObjectProtocol` |
| Store `[Data]`, not file URLs | Keeps the whole journal inside the Core Data store — no orphan files after delete |

---

## 📚 Lesson 7.5: Search & Weather Filter (45 minutes)

**Goal:** two inputs — free text + a weather chip — combined through a single
`filter(_:)` on the view model. Same pattern as Week 6, now with a second dimension.

```swift
// Journal/ViewModels/JournalViewModel.swift
class JournalViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var weatherFilter: Weather? = nil

    func filter(_ entries: [JournalEntry]) -> [JournalEntry] {
        var result = entries

        if let weatherFilter {
            result = result.filter { $0.weatherTag == weatherFilter }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { entry in
                contains(entry.title, query) || contains(entry.content, query)
            }
        }
        return result
    }

    private func contains(_ haystack: String?, _ needle: String) -> Bool {
        haystack?.localizedCaseInsensitiveContains(needle) ?? false
    }
}
```

The chip row at the top of the timeline:

```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 8) {
        chip(for: nil, label: "ទាំងអស់", symbol: "line.3.horizontal.decrease.circle")
        ForEach(Weather.allCases) { weather in
            chip(for: weather, label: weather.label, symbol: weather.symbolName)
        }
    }
}
```

Tapping the same chip again toggles it off — `nil` means "all":

```swift
Button {
    viewModel.weatherFilter = isSelected ? nil : weather
} label: { … }
```

> **Why `nil`-biased filtering?** A `Weather?` filter has three states in UI
> but only two in code: "all" (`nil`) and "this one". That means one less
> enum case to maintain and one less state to test.

> **Why filter in Swift, not with an `NSPredicate` on the fetch?**
> Re-issuing the fetch on every keystroke hits the SQLite store every
> character. Swift-side `.filter` on the already-fetched results is
> instant for a few hundred entries — and it's what Apple Notes does.

| Design choice | Why |
|---|---|
| Single `filter(_:)` on the VM | One function to test — and it composes text + weather without duplicating iterations |
| `localizedCaseInsensitiveContains` | Works for Khmer and Latin scripts; matches user expectations |
| Custom `SearchBar` (reused from Week 6) | `.searchable` is iOS 15+ — our bar lives at the top of the `VStack`, not pinned by the nav bar |

---

## 🎨 UI / UX Suggestions

| Element | Suggestion |
|---|---|
| Tab icon | `book` SF Symbol (selected: `book.closed.fill`), Khmer label *កំណត់ហេតុ* |
| Timeline row | Time chip on the left, bold title + 2-line snippet in the middle, weather icon + photo count on the right |
| Section header | `EEEE, MMMM d` — e.g. "Tuesday, April 23" |
| Weather chip row | Horizontal `ScrollView` under the search bar; selected chip filled with the weather's tint |
| Detail header | Full-width weather badge chip tinted by `weather.tint` — yellow sun, blue rain, gray cloud, teal wind |
| Detail body | `TextEditor` for a rich-text *feel* (iOS 13 `TextEditor` renders plain text with system font) |
| Photo gallery | Horizontal `ScrollView` of 96pt square thumbnails — tap to open full-size in a sheet |
| Expandable sections | "រូបភាព" (open by default) + "ព័ត៌មានលម្អិត" (closed by default) — same `ExpandableSection` convention as Week 6 |
| Add / Edit sheet | `Form` with four sections — Title, Weather, Content, Photos; Save disabled until content is non-empty |

**Suggested SF Symbols:**

| Purpose | Symbol |
|---|---|
| Tab | `book` / `book.closed.fill` |
| Sunny | `sun.max.fill` |
| Rainy | `cloud.rain.fill` |
| Cloudy | `cloud.fill` |
| Windy | `wind` |
| Photo gallery | `photo.on.rectangle` |
| Add photo | `camera` |
| Search | `magnifyingglass` |
| Clear filter / "All" chip | `line.3.horizontal.decrease.circle` |
| Metadata section | `info.circle` |
| Add entry | `plus` |

---

## 🌐 Offline-First — What Does It Really Mean?

| Need | Weak approach | Strong approach |
|---|---|---|
| First launch | Wait for server auth before the journal is usable | Journal opens empty, ready for the first entry — no network |
| Weather | Fetch the current forecast from an API every time | User picks the weather themselves — it's *their* journal |
| Photos | Upload to a cloud, store a URL | Store JPEG `Data` inside the Core Data store |
| Privacy | Entries leave the device | Entries never touch the network |
| Airplane mode | Blocked or degraded | Full app works exactly the same |

> **Rule of thumb:** a journal's weather is not the meteorological truth —
> it's the *felt* weather as the user remembers it. That's why Apple's own
> Weather app is a separate app from Notes: different jobs, different data.

---

### Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Leaving Codegen on "Class Definition" | Duplicate `JournalEntry` class error at build time | Data Model Inspector → Codegen → *Manual/None* |
| Using `PhotosPicker` | Won't compile on iOS 13–15 | Use `UIImagePickerController` wrapped in `UIViewControllerRepresentable` |
| Holding photos as `[UIImage]` on the entry | Lost on app relaunch | Store `[Data]` (JPEG) via the `photos` transformable attribute |
| `.searchable(text: $query)` | iOS 15+ only | Put the Week 6 `SearchBar` above the `List` inside a `VStack` |
| `ascending: true` on the date sort | Oldest entries on top — opposite of a journal | `ascending: false` — newest first |
| Transformable without a registered transformer | Runtime warning *"Unable to load class NSUnarchiveFromData"* | Set *Transformer* = `NSSecureUnarchiveFromData` and *Custom Class* = `NSArray` |
| Saving `[Data]` with `setValue(…, forKey:)` directly | Crash on fetch if the transformer isn't in place | Cast through `as NSArray` — `entry.photos = [Data] as NSArray` |
| Keeping `TextEditor` text in `@State` and never writing it back | User types, taps save, nothing persists | In the Add/Edit sheet's `save()`, assign `entry.content = content` before `context.save()` |
| Filtering inside `@FetchRequest(predicate:)` on every keystroke | Re-fetches SQLite on every character | Filter in Swift on the already-fetched `entries` via the ViewModel |
| Setting `weather` with a raw string literal | Silent drift — `"Sunny"` vs `"sunny"` don't match the enum | Always use `Weather.sunny.rawValue` — the enum is the single source of truth |

---

*End of Week 7 Materials — Daily Journal Module*
