# Week 5 : Calendar & Reminders Module (Project 2)
## CalendarTabView
## Topic: Scheduling activities with local notifications

---

**Learning Objectives**

By the end of this week, students will be able to:
- Build a calendar view with DatePicker and custom grid
- Create the FarmActivity Core Data model with date, type, notes
- Request notification permissions from the user
- Schedule local notifications with UNUserNotificationCenter
- Handle notification tap to open a specific activity (deep-linking)

---

## ⚠️ iOS 13+ API Rules (Quick Reference)

| Feature | ❌ iOS 17+ Only | ✅ iOS 13+ Correct |
|---|---|---|
| ViewModel | `@Observable class VM` | `class VM: ObservableObject` |
| State ViewModel | `@State var vm: VM` | `@StateObject var vm: VM` |
| Read ViewModel | `@Environment(VM.self)` | `@EnvironmentObject var vm: VM` |
| Pass ViewModel | `.environment(vm)` | `.environmentObject(vm)` |
| Navigation | `NavigationStack` | `NavigationView` |

---

**Lesson Breakdown:**

| Lesson | Topic |
|--------|-------|
| 5.1 | Building a calendar view with DatePicker and custom grid |
| 5.2 | Creating the FarmActivity model with date, type, notes |
| 5.3 | Requesting notification permissions |
| 5.4 | Scheduling local notifications with UNUserNotificationCenter |
| 5.5 | Handling notification tap to open specific activity |

---

## 📚 Lesson 5.1: Building a Calendar View with DatePicker and Custom Grid (45 minutes)

**Goal:** Replace the plain activity list with a month-grid calendar.
Tapping a day filters the list to activities for that date.

**Architecture overview:**

```
CalendarTabView
├── CalendarGridView          ← month grid (prev / next)
│   └── DayCellView           ← one cell per day (selected, today, has-activities)
├── Activity list              ← filtered by selectedDate
│   └── ActivityRowView        ← one row per activity
└── AddActivityView (sheet)    ← pre-filled with selectedDate
```

**CalendarTabView — main container:**

```swift
// Views/CalendarTabView.swift
import SwiftUI
import CoreData

struct CalendarTabView: View {
    @EnvironmentObject private var viewModel: FarmViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: FarmActivity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FarmActivity.date, ascending: true)]
    ) var activities: FetchedResults<FarmActivity>

    @State private var selectedDate = Date()
    @State private var showingAddActivity = false

    /// Filter activities to only those matching the selected calendar date
    private var activitiesForSelectedDate: [FarmActivity] {
        activities.filter { activity in
            guard let activityDate = activity.date else { return false }
            return Calendar.current.isDate(activityDate, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom calendar grid
                CalendarGridView(
                    selectedDate: $selectedDate,
                    activities: activities
                )
                .padding()

                Divider()

                // Activity list for selected date
                if activitiesForSelectedDate.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("គ្មានសកម្មភាពសម្រាប់ថ្ងៃនេះ")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(activitiesForSelectedDate, id: \.self) { activity in
                            ActivityRowView(activity: activity, viewModel: viewModel)
                        }
                        .onDelete(perform: deleteActivities)
                    }
                }
            }
            .navigationTitle("ប្រតិទិនកសិកម្ម")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddActivity = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(viewModel)
            }
            // Deep link: when a notification is tapped, jump to the activity's date
            .onReceive(
                NotificationCenter.default.publisher(for: .didTapActivityNotification)
            ) { notification in
                if let activityID = notification.userInfo?["activityID"] as? UUID,
                   let activity = activities.first(where: { $0.id == activityID }),
                   let date = activity.date {
                    selectedDate = date
                }
            }
        }
    }

    private func deleteActivities(offsets: IndexSet) {
        let toDelete = offsets.map { activitiesForSelectedDate[$0] }
        for activity in toDelete {
            // Remove scheduled notification before deleting
            if activity.reminderEnabled, let id = activity.id {
                NotificationManager.shared.removeNotification(id: id)
            }
            viewContext.delete(activity)
        }
        try? viewContext.save()
    }
}
```

> **Key design:** The list shows only activities for `selectedDate`, not all
> activities. The `activitiesForSelectedDate` computed property filters using
> `Calendar.isDate(_:inSameDayAs:)`. The `.onReceive` handler listens for
> notification taps and navigates to the tapped activity's date (see Lesson 5.5).

**CalendarGridView — custom month grid:**

```swift
struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let activities: FetchedResults<FarmActivity>

    private let calendar = Calendar.current
    private let daysOfWeek = ["អា", "ច", "អ", "ព", "ព្រ", "សុ", "ស"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    /// Build array of optional dates — leading nils are blank cells before the 1st
    private var daysInMonth: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }

        let weekday = calendar.component(.weekday, from: firstOfMonth)
        var days: [Date?] = Array(repeating: nil, count: weekday - 1)
        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth))
        }
        return days
    }

    private func hasActivities(on date: Date) -> Bool {
        activities.contains { activity in
            guard let d = activity.date else { return false }
            return calendar.isDate(d, inSameDayAs: date)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Month header with prev / next
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthTitle).font(.headline)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // 7-column LazyVGrid
            LazyVGrid(columns: columns, spacing: 8) {
                // Day-of-week headers
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day).font(.caption).foregroundColor(.gray)
                }
                // Day cells
                ForEach(daysInMonth.indices, id: \.self) { index in
                    if let date = daysInMonth[index] {
                        DayCellView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasActivities: hasActivities(on: date)
                        )
                        .onTapGesture { selectedDate = date }
                    } else {
                        Text("").frame(height: 36)  // blank leading cell
                    }
                }
            }
        }
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}
```

**DayCellView — one cell per day:**

```swift
struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasActivities: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue
                              : isToday ? Color.blue.opacity(0.2)
                              : Color.clear)
                )
                .foregroundColor(isSelected ? .white : .primary)

            // Green dot when the date has activities
            Circle()
                .fill(hasActivities ? Color.green : Color.clear)
                .frame(width: 6, height: 6)
        }
    }
}
```

> **How the grid works:**
>
> 1. `daysInMonth` builds an array with `nil` placeholders for days before the 1st
>    (e.g. if the 1st is Wednesday, indices 0-2 are `nil`).
> 2. `LazyVGrid` with 7 columns wraps them into a calendar layout.
> 3. A green dot under a day means at least one `FarmActivity.date` falls on that day.
> 4. `selectedDate` is `@Binding` — tapping a day updates the parent's state,
>    which re-filters the activity list.

---

## 📚 Lesson 5.2: Creating the FarmActivity Model with Date, Type, Notes (45 minutes)

The FarmActivity entity was created in the Core Data model editor.
Below are the manual model files — set Codegen to **"Manual/None"** in the
Data Model Inspector to avoid duplicate symbols.

```swift
// Models/FarmActivity+CoreDataClass.swift
import Foundation
import CoreData

@objc(FarmActivity)
public class FarmActivity: NSManagedObject {

}
```

```swift
// Models/FarmActivity+CoreDataProperties.swift
import Foundation
import CoreData

extension FarmActivity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FarmActivity> {
        return NSFetchRequest<FarmActivity>(entityName: "FarmActivity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var activityType: String?   // "ដាំដំណាំ", "ស្រោចទឹក", etc.
    @NSManaged public var date: Date?
    @NSManaged public var notes: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var reminderEnabled: Bool    // drives local notification
}

extension FarmActivity: Identifiable {}
```

| Attribute | Type | Purpose |
|-----------|------|---------|
| `id` | UUID | Unique identifier (also used as notification ID) |
| `title` | String | Activity name shown in the list |
| `activityType` | String | Category — planting, watering, spraying, etc. |
| `date` | Date | Scheduled date & time |
| `notes` | String | Optional description |
| `isCompleted` | Bool | Checkbox state |
| `reminderEnabled` | Bool | Whether a local notification is scheduled |

**ActivityRowView — uses `@ObservedObject` for instant UI updates:**

> Use `@ObservedObject` (not `let`) so the view re-renders instantly
> when `isCompleted` is toggled — same pattern as `TransactionRowView`.

```swift
struct ActivityRowView: View {
    @ObservedObject var activity: FarmActivity
    let viewModel: FarmViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(activity.isCompleted ? .green : .gray)
                .font(.title2)
                .onTapGesture {
                    activity.isCompleted.toggle()
                    try? activity.managedObjectContext?.save()
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title ?? "")
                    .font(.headline)
                    .strikethrough(activity.isCompleted)

                Text(activity.activityType ?? "")
                    .font(.caption)
                    .foregroundColor(.blue)

                if let date = activity.date {
                    Text(viewModel.formatDate(date))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if activity.reminderEnabled {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
```

---

## 📚 Lesson 5.3: Requesting Notification Permissions (45 minutes)

Before scheduling any local notification, the app must ask the user for
permission. This only shows the system prompt once — subsequent calls return
the stored answer.

**Process flow:**

```
App launches
    │
    ▼
AppDelegate.didFinishLaunching
    │
    ▼
NotificationManager.requestPermission()
    │
    ▼
iOS shows permission dialog (first time only)
    │
    ├── User taps "Allow"  → granted = true  → notifications work
    └── User taps "Don't Allow" → granted = false → reminders silently skip
```

**NotificationManager — singleton utility:**

```swift
// Utilities/NotificationManager.swift
import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    // MARK: - Request Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
```

> **Why `DispatchQueue.main.async`?**
> `requestAuthorization` calls back on a background thread.
> Any UI update (e.g. showing an alert) must happen on the main thread.

**Requesting permission at app launch:**

```swift
// SmartFarmerAssistantFinishApp.swift
import SwiftUI
import UserNotifications

@main
struct SmartFarmerAssistantFinishApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let context = CoreDataManager.shared.context

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, context)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.shared.requestPermission { _ in }
        return true
    }
}
```

| UNAuthorizationOptions | What it enables |
|------------------------|-----------------|
| `.alert` | Banner / lock-screen notification |
| `.badge` | Red badge number on app icon |
| `.sound` | Notification sound |

---

## 📚 Lesson 5.4: Scheduling Local Notifications with UNUserNotificationCenter (45 minutes)

**When the user saves an activity with `reminderEnabled = true`,
schedule a notification 1 hour before the activity date.**

**Notification scheduling flow:**

```
User taps "រក្សាទុក" (Save) in AddActivityView
    │
    ▼
FarmActivity saved to Core Data
    │
    ▼
if reminderEnabled {
    NotificationManager.scheduleNotification(for: activity)
}
    │
    ▼
UNMutableNotificationContent created
    │  - title: "កម្មវិធីកសិកម្ម"
    │  - body:  activity title + notes
    │  - userInfo: ["activityID": UUID string]
    │
    ▼
UNCalendarNotificationTrigger
    │  - fires 1 hour before activity.date
    │
    ▼
UNNotificationRequest added to UNUserNotificationCenter
    │
    ▼
iOS delivers the notification at the trigger time
```

**NotificationManager — schedule & remove:**

```swift
    // MARK: - Schedule Notification

    func scheduleNotification(for activity: FarmActivity) {
        guard activity.reminderEnabled,
              let id = activity.id,
              let date = activity.date,
              let title = activity.title else { return }

        let content = UNMutableNotificationContent()
        content.title = "កម្មវិធីកសិកម្ម"
        content.body = title
        if let notes = activity.notes, !notes.isEmpty {
            content.body += " — \(notes)"
        }
        content.sound = .default
        // Store the activity ID so we can deep-link on tap
        content.userInfo = ["activityID": id.uuidString]

        // Trigger 1 hour before the activity date
        let triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: date) ?? date
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: id.uuidString,   // same ID = replaces previous
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Remove Notification

    func removeNotification(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id.uuidString]
        )
    }
}
```

| Class | Role |
|-------|------|
| `UNMutableNotificationContent` | What the user sees (title, body, sound) |
| `UNCalendarNotificationTrigger` | When it fires (date components) |
| `UNNotificationRequest` | Combines content + trigger; `identifier` is unique per activity |

> **Why use `id.uuidString` as the notification identifier?**
> - Each activity gets exactly one notification
> - Re-saving the same activity replaces the old notification
> - Deleting the activity can remove the pending notification by ID

**AddActivityView — schedule notification on save:**

```swift
struct AddActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var title = ""
    @State private var activityType = "ដាំដំណាំ"
    @State private var notes = ""
    @State private var date: Date
    @State private var reminderEnabled = false

    let activityTypes = ["ដាំដំណាំ", "ស្រោចទឹក", "បាញ់ថ្នាំ", "ច្រូតកាត់", "ផ្សេងៗ"]

    /// Accept the selected date from CalendarTabView
    init(selectedDate: Date = Date()) {
        _date = State(initialValue: selectedDate)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ព័ត៌មានសកម្មភាព")) {
                    TextField("ចំណងជើង", text: $title)
                    Picker("ប្រភេទ", selection: $activityType) {
                        ForEach(activityTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    DatePicker("កាលបរិច្ឆេទ", selection: $date,
                               displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("កំណត់ចំណាំ")) {
                    TextField("បញ្ចូលកំណត់ចំណាំ...", text: $notes)
                }
                Section {
                    Toggle("បើកការរំលឹក", isOn: $reminderEnabled)
                }
            }
            .navigationTitle("បន្ថែមសកម្មភាព")
            .navigationBarItems(
                leading: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("រក្សាទុក") {
                    saveActivity()
                }
                .disabled(title.isEmpty)
            )
        }
    }

    private func saveActivity() {
        let activity = FarmActivity(context: viewContext)
        activity.id = UUID()
        activity.title = title
        activity.activityType = activityType
        activity.notes = notes
        activity.date = date
        activity.isCompleted = false
        activity.reminderEnabled = reminderEnabled

        try? viewContext.save()

        // Schedule local notification when reminder is enabled
        if reminderEnabled {
            NotificationManager.shared.scheduleNotification(for: activity)
        }

        presentationMode.wrappedValue.dismiss()
    }
}
```

> **Key points in AddActivityView:**
>
> | What | Why |
> |---|---|
> | `init(selectedDate:)` | Pre-fills DatePicker to the day tapped in calendar |
> | `displayedComponents: [.date, .hourAndMinute]` | Notification needs a time, not just a date |
> | `NotificationManager.scheduleNotification(for:)` on save | Actually schedules the reminder |

---

## 📚 Lesson 5.5: Handling Notification Tap to Open Specific Activity (45 minutes)

**Goal:** When the user taps a notification, the app should:
1. Switch to the Calendar tab
2. Select the date of the activity
3. The activity appears in the filtered list

**Deep-link flow:**

```
User taps notification banner
    │
    ▼
AppDelegate.didReceive(response:)
    │  reads activityID from userInfo
    │
    ▼
Posts .didTapActivityNotification via NotificationCenter
    │  (userInfo: ["activityID": UUID])
    │
    ▼
MainTabView.onReceive
    │  selectedTab = 1 (Calendar)
    │
    ▼
CalendarTabView.onReceive
    │  finds activity by ID
    │  selectedDate = activity.date
    │
    ▼
Activity list filters to that date → activity is visible
```

**Step 1 — Define the Notification.Name:**

```swift
// In SmartFarmerAssistantFinishApp.swift
extension Notification.Name {
    static let didTapActivityNotification = Notification.Name("didTapActivityNotification")
}
```

**Step 2 — AppDelegate handles the tap:**

```swift
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.shared.requestPermission { _ in }
        return true
    }

    // Called when user taps a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let idString = userInfo["activityID"] as? String,
           let activityID = UUID(uuidString: idString) {
            NotificationCenter.default.post(
                name: .didTapActivityNotification,
                object: nil,
                userInfo: ["activityID": activityID]
            )
        }
        completionHandler()
    }

    // Show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
```

| Delegate method | When it's called |
|-----------------|------------------|
| `willPresent` | Notification arrives while app is **in foreground** |
| `didReceive` | User **taps** the notification |

**Step 3 — MainTabView switches to Calendar tab:**

```swift
// In MainTabView body, add after .environmentObject(financeCoordinator):
.onReceive(
    NotificationCenter.default.publisher(for: .didTapActivityNotification)
) { _ in
    selectedTab = 1   // Switch to Calendar tab
}
```

**Step 4 — CalendarTabView selects the activity's date:**

```swift
// In CalendarTabView body, add after .sheet:
.onReceive(
    NotificationCenter.default.publisher(for: .didTapActivityNotification)
) { notification in
    if let activityID = notification.userInfo?["activityID"] as? UUID,
       let activity = activities.first(where: { $0.id == activityID }),
       let date = activity.date {
        selectedDate = date
    }
}
```

> **Why use `NotificationCenter.default` (Foundation) instead of passing data directly?**
>
> `AppDelegate` does not have a reference to `MainTabView` or `CalendarTabView`.
> Foundation's `NotificationCenter` acts as a decoupled event bus:
> - **Publisher:** `AppDelegate.didReceive` posts the event
> - **Subscribers:** `MainTabView` and `CalendarTabView` each react independently
>
> This keeps the AppDelegate free of SwiftUI dependencies.

---

### Complete Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                   AddActivityView                            │
│                                                              │
│  [Tap Save] ──► FarmActivity saved to Core Data             │
│                         │                                    │
│           if reminderEnabled                                 │
│                         │                                    │
│                         ▼                                    │
│           NotificationManager.scheduleNotification()         │
│                         │                                    │
│                         ▼                                    │
│           UNUserNotificationCenter stores request            │
│                         │                                    │
│    ┌────────────────────┘                                    │
│    │                                                         │
│    ▼  (at trigger time)                                      │
│  iOS delivers notification                                   │
│    │                                                         │
│    ▼  (user taps)                                            │
│  AppDelegate.didReceive                                      │
│    │                                                         │
│    ▼                                                         │
│  NotificationCenter.post(.didTapActivityNotification)        │
│    │                                                         │
│    ├──► MainTabView: selectedTab = 1 (Calendar)             │
│    └──► CalendarTabView: selectedDate = activity.date       │
│                         │                                    │
│                         ▼                                    │
│           Activity list filters → activity visible           │
└──────────────────────────────────────────────────────────────┘
```

---

### Common Notification Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Forget to set `delegate = self` | `didReceive` never called | Set delegate in `didFinishLaunching` |
| Don't request permission | Notifications silently fail | Call `requestPermission()` at launch |
| Use `repeats: true` with full date | Crash — repeating triggers need partial components | Use `repeats: false` for one-time events |
| Forget `DispatchQueue.main.async` | UI update on background thread → crash | Always dispatch to main in completion |
| Don't store ID in `userInfo` | Can't deep-link on tap | Always include the activity UUID |
| Forget to remove notification on delete | Ghost notification fires for deleted activity | Call `removeNotification(id:)` before delete |

---

*End of Week 5 Materials - Calendar & Reminders Module*
