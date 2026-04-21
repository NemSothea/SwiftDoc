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

> `NavigationView` is deprecated from iOS 16 but still works. This course
> stays with it for broad device support; for iOS 16+ only projects, prefer
> `NavigationStack`.

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
│   └── ActivityRowContent     ← one row per activity (inside a NavigationLink)
├── AddActivityView (sheet)    ← pre-filled with the tapped date
├── EditActivityView (sheet)   ← opened from ActivityDetailView
└── ActivityDetailView         ← pushed via NavigationLink from a row
```

**CalendarTabView — main container:**

```swift
// CalendarReminders/Views/CalendarTabView.swift
import SwiftUI
import CoreData

struct CalendarTabView: View {
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
                            // Toggle button is kept OUTSIDE the NavigationLink so
                            // tapping the checkbox doesn't also push the detail view.
                            HStack(spacing: 12) {
                                Button {
                                    activity.isCompleted.toggle()
                                    if activity.isCompleted,
                                       activity.reminderEnabled,
                                       let id = activity.id {
                                        NotificationManager.shared.cancelNotification(for: id)
                                    }
                                    try? activity.managedObjectContext?.save()
                                } label: {
                                    Image(systemName: activity.isCompleted
                                          ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(activity.isCompleted ? .green : .gray)
                                }
                                .buttonStyle(BorderlessButtonStyle())

                                NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                    ActivityRowContent(activity: activity, viewModel: viewModel)
                                }
                            }
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
                AddActivityView(initialDate: selectedDate)
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
            // Cancel scheduled notification before deleting the row
            if activity.reminderEnabled, let id = activity.id {
                NotificationManager.shared.cancelNotification(for: id)
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

    // Two separate pieces of state:
    //   selectedDate  — which day the user picked (drives the activity list)
    //   displayedMonth — which month the grid is currently showing
    // Keeping them apart means the ‹ › chevrons don't move the user's selection.
    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["អា", "ច", "អ", "ពុ", "ព្រ", "សុ", "ស"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 10) {
            // Month / year header with prev / next
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(monthYearString).font(.title3.bold())
                    Text(yearString).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal, 4)

            // Day-of-week headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day).font(.caption.bold()).foregroundColor(.gray)
                }
            }

            // Day cells — blank leading cells then 1…numberOfDaysInMonth
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach((-firstWeekdayOffset)..<0, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }
                ForEach(1...numberOfDaysInMonth, id: \.self) { day in
                    DayCellView(
                        day: day,
                        isToday: isToday(day),
                        isSelected: isSelected(day),
                        hasActivities: hasActivities(on: day)
                    )
                    .onTapGesture { selectDay(day) }
                }
            }
        }
        // If selectedDate is changed externally (e.g. from a notification tap)
        // and falls in a different month, follow it.
        .onChange(of: selectedDate) { newDate in
            let sel  = calendar.dateComponents([.year, .month], from: newDate)
            let disp = calendar.dateComponents([.year, .month], from: displayedMonth)
            if sel.year != disp.year || sel.month != disp.month {
                displayedMonth = newDate
            }
        }
    }

    // MARK: - Calendar math (all derive from displayedMonth)

    private var monthYearString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM"
        fmt.locale = Locale(identifier: "km_KH")
        return fmt.string(from: displayedMonth)
    }

    private var yearString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy"
        return fmt.string(from: displayedMonth)
    }

    private var firstDayOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
    }

    private var firstWeekdayOffset: Int {
        // Sunday = 1, so subtract 1 to get the number of leading blank cells
        calendar.component(.weekday, from: firstDayOfMonth) - 1
    }

    private var numberOfDaysInMonth: Int {
        calendar.range(of: .day, in: .month, for: displayedMonth)!.count
    }

    private func dateFor(_ day: Int) -> Date? {
        var comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        comps.day = day
        return calendar.date(from: comps)
    }

    private func isToday(_ day: Int) -> Bool {
        guard let d = dateFor(day) else { return false }
        return calendar.isDateInToday(d)
    }

    private func isSelected(_ day: Int) -> Bool {
        guard let d = dateFor(day) else { return false }
        return calendar.isDate(d, inSameDayAs: selectedDate)
    }

    private func hasActivities(on day: Int) -> Bool {
        guard let d = dateFor(day) else { return false }
        return activities.contains { activity in
            guard let aDate = activity.date else { return false }
            return calendar.isDate(aDate, inSameDayAs: d)
        }
    }

    private func selectDay(_ day: Int) {
        if let d = dateFor(day) { selectedDate = d }
    }

    private func previousMonth() {
        if let m = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = m
        }
    }

    private func nextMonth() {
        if let m = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = m
        }
    }
}
```

**DayCellView — one cell per day:**

```swift
struct DayCellView: View {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let hasActivities: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text("\(day)")
                .font(.system(size: 15, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor)
                .frame(width: 34, height: 34)
                .background(bgColor)
                .clipShape(Circle())

            // Green dot when the day has activities
            Circle()
                .fill(hasActivities ? Color.green : Color.clear)
                .frame(width: 6, height: 6)
        }
        .frame(height: 44)
    }

    // Selected must win over today's highlight — keep this order.
    private var textColor: Color {
        if isSelected { return .white }
        if isToday    { return .blue }
        return .primary
    }

    private var bgColor: Color {
        if isSelected { return .blue }
        if isToday    { return Color.blue.opacity(0.15) }
        return .clear
    }
}
```

> **How the grid works:**
>
> 1. `firstWeekdayOffset` produces the number of blank leading cells (e.g. if
>    the 1st is Wednesday, we render 3 blanks before day 1).
> 2. `LazyVGrid` with 7 columns wraps the blanks + days into a calendar layout.
> 3. A green dot under a day means at least one `FarmActivity.date` falls on it.
> 4. `selectedDate` is `@Binding` — tapping a day updates the parent's state,
>    which re-filters the activity list.
> 5. `displayedMonth` is `@State` local to the grid, so the ‹ › chevrons scroll
>    the visible month **without** changing the user's selection.

---

## 📚 Lesson 5.2: Creating the FarmActivity Model with Date, Type, Notes (45 minutes)

The FarmActivity entity was created in the Core Data model editor.
Below are the manual model files — set Codegen to **"Manual/None"** in the
Data Model Inspector to avoid duplicate symbols.

```swift
// CalendarReminders/Models/FarmActivity+CoreDataClass.swift
import Foundation
import CoreData

@objc(FarmActivity)
public class FarmActivity: NSManagedObject {

}
```

```swift
// CalendarReminders/Models/FarmActivity+CoreDataProperties.swift
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

**ActivityRowContent — the row content used inside the NavigationLink:**

> In `CalendarTabView`, the checkbox button is built in the parent so the
> `NavigationLink` only wraps the row content. `ActivityRowContent` below
> focuses on the title / type / time / reminder-bell layout.

```swift
struct ActivityRowContent: View {
    @ObservedObject var activity: FarmActivity

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title ?? "")
                    .font(.headline)
                    .strikethrough(activity.isCompleted)
                    .foregroundColor(activity.isCompleted ? .gray : .primary)

                HStack(spacing: 6) {
                    Label(activity.activityType ?? "",
                          systemImage: iconForType(activity.activityType))
                        .font(.caption)
                        .foregroundColor(.blue)

                    if let date = activity.date {
                        Text(timeString(from: date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
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

    private func timeString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }

    /// Map Khmer activity types to SF Symbols. Keep in sync with `activityTypes`
    /// in AddActivityView / EditActivityView.
    private func iconForType(_ type: String?) -> String {
        switch type {
        case "ដាំដំណាំ":  return "leaf.fill"
        case "ស្រោចទឹក":  return "drop.fill"
        case "បាញ់ថ្នាំ":   return "sprinkler.and.droplets"
        case "ច្រូតកាត់":  return "scissors"
        default:           return "ellipsis.circle"
        }
    }
}
```

> Use `@ObservedObject` (not `let`) so the view re-renders instantly when
> `isCompleted` is toggled — same pattern as `TransactionRowView`.

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
NotificationManager.shared is created as @StateObject
    │  (its init sets itself as UNUserNotificationCenter delegate)
    │
    ▼
User toggles "បើកការរំលឹក" on an activity
    │
    ▼
NotificationManager.requestPermission()
    │
    ▼
iOS shows the permission dialog (first time only)
    │
    ├── User taps "Allow"  → isAuthorized = true  → notifications work
    └── User taps "Don't Allow" → isAuthorized = false → show a "open Settings" alert
```

> **No AppDelegate needed.** The shipped app is pure SwiftUI — permissions,
> scheduling, and delegate callbacks all live inside `NotificationManager`,
> which is instantiated at the top of the `App` struct.

**NotificationManager — singleton + delegate + observable:**

```swift
// CalendarReminders/Services/NotificationManager.swift
import Foundation
import UserNotifications
import CoreData

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    // Published so views (e.g. a Settings screen) can react to permission changes
    @Published var isAuthorized = false

    private override init() {
        super.init()
        // Register as the delegate immediately, BEFORE any notification arrives
        UNUserNotificationCenter.current().delegate = self
        checkAuthorization()
    }

    // MARK: - Request Permission

    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                completion(granted)
            }
        }
    }

    /// Re-check on every app foreground — the user may have toggled
    /// notifications in Settings while the app was backgrounded.
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
```

> **Why `DispatchQueue.main.async`?**
> `requestAuthorization` and `getNotificationSettings` both call back on a
> background thread. Mutating `@Published` state (which drives SwiftUI) must
> happen on the main thread.

**Wiring the manager into the App struct:**

```swift
// SmartFarmerAssistantFinishApp.swift
import SwiftUI
import CoreData

@main
struct SmartFarmerAssistantFinishApp: App {
    let context = CoreDataManager.shared.context

    // Create the manager early so its init registers the delegate
    // before any notification can arrive.
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, context)
                .environmentObject(notificationManager)
                .onAppear {
                    // Re-check authorisation on every foreground
                    notificationManager.checkAuthorization()
                }
        }
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

**When the user saves an activity with `reminderEnabled = true`, schedule a
notification that fires at the exact reminder time the user picked.** The
user chooses both the activity date and a separate reminder time inside
`AddActivityView`; the two are merged into `activity.date`.

**Notification scheduling flow:**

```
User taps "រក្សាទុក" (Save) in AddActivityView
    │
    ▼
FarmActivity saved to Core Data (date = day + reminderTime merged)
    │
    ▼
if reminderEnabled {
    NotificationManager.scheduleNotification(for: activity)
}
    │
    ▼
UNMutableNotificationContent created
    │  - title: "🌾 កម្មវិធីកសិកម្ម"
    │  - body:  activity title + notes
    │  - userInfo: ["activityID": UUID string]
    │
    ▼
UNCalendarNotificationTrigger
    │  - fires at activity.date (year/month/day/hour/minute)
    │  - past dates are silently skipped
    │
    ▼
UNNotificationRequest added to UNUserNotificationCenter
    │
    ▼
iOS delivers the notification at the trigger time
```

**NotificationManager — schedule & cancel:**

```swift
    // MARK: - Schedule Notification

    func scheduleNotification(for activity: FarmActivity) {
        guard let id = activity.id,
              let title = activity.title,
              let date = activity.date else { return }

        // Don't schedule notifications in the past
        guard date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "🌾 កម្មវិធីកសិកម្ម"
        content.body = title
        if let notes = activity.notes, !notes.isEmpty {
            content.body += " — \(notes)"
        }
        content.sound = .default
        // Store the activity ID so we can deep-link on tap
        content.userInfo = ["activityID": id.uuidString]

        // Fire at the exact date + time stored on the activity
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: id.uuidString,   // same ID = replaces previous
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel Notification

    func cancelNotification(for activityID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [activityID.uuidString]
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
    @State private var reminderTime: Date
    @State private var showPermissionAlert = false

    let activityTypes = ["ដាំដំណាំ", "ស្រោចទឹក", "បាញ់ថ្នាំ", "ច្រូតកាត់", "ផ្សេងៗ"]

    /// Accept the selected date from CalendarTabView
    init(initialDate: Date = Date()) {
        _date = State(initialValue: initialDate)
        _reminderTime = State(initialValue: initialDate)
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
                               displayedComponents: .date)
                }

                Section(header: Text("កំណត់ចំណាំ")) {
                    TextEditor(text: $notes).frame(minHeight: 60)
                }

                Section(header: Text("ការរំលឹក")) {
                    Toggle("បើកការរំលឹក", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { enabled in
                            if enabled { requestNotificationPermission() }
                        }

                    if reminderEnabled {
                        DatePicker("ម៉ោងរំលឹក", selection: $reminderTime,
                                   displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("បន្ថែមសកម្មភាព")
            .navigationBarItems(
                leading: Button("បោះបង់") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("រក្សាទុក") { saveActivity() }
                    .disabled(title.isEmpty)
            )
            .alert(isPresented: $showPermissionAlert) {
                Alert(
                    title: Text("ការអនុញ្ញាត"),
                    message: Text("សូមបើកការជូនដំណឹងនៅក្នុង Settings ដើម្បីប្រើមុខងារការរំលឹក។"),
                    primaryButton: .default(Text("បើក Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel(Text("បោះបង់")) { reminderEnabled = false }
                )
            }
        }
    }

    // MARK: - Save

    private func saveActivity() {
        let activity = FarmActivity(context: viewContext)
        activity.id = UUID()
        activity.title = title
        activity.activityType = activityType
        activity.notes = notes
        activity.isCompleted = false
        activity.reminderEnabled = reminderEnabled

        // Merge the picked date with the reminder time so activity.date
        // carries both (the notification trigger reads year+month+day+hour+minute).
        activity.date = reminderEnabled
            ? combineDateAndTime(date: date, time: reminderTime)
            : date

        try? viewContext.save()

        if reminderEnabled {
            NotificationManager.shared.scheduleNotification(for: activity)
        }

        presentationMode.wrappedValue.dismiss()
    }

    // MARK: - Permission

    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermission { granted in
            if !granted { showPermissionAlert = true }
        }
    }

    // MARK: - Helpers

    /// Merges the date portion of one Date with the hour/minute of another.
    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        let d = cal.dateComponents([.year, .month, .day], from: date)
        let t = cal.dateComponents([.hour, .minute], from: time)
        var merged = DateComponents()
        merged.year = d.year;  merged.month  = d.month;  merged.day    = d.day
        merged.hour = t.hour;  merged.minute = t.minute
        return cal.date(from: merged) ?? date
    }
}
```

> **Key points in AddActivityView:**
>
> | What | Why |
> |---|---|
> | `init(initialDate:)` | Pre-fills the date picker to the day tapped in the calendar |
> | Separate `reminderTime` state | Keeps the day and the clock independent — user picks both |
> | `combineDateAndTime(date:time:)` | Merges them into one `Date` stored on the activity |
> | `.onChange(of: reminderEnabled)` → permission | Requests permission only when the user actually wants a reminder |
> | Alert with `openSettingsURLString` | Gracefully handles denied permission instead of silently failing |
> | `NotificationManager.scheduleNotification(for:)` on save | Actually schedules the reminder |

> **`EditActivityView` mirrors this** with one extra step: before
> re-scheduling, it calls `cancelNotification(for:)` on the activity's UUID
> so the old pending notification can't fire after the user changes the
> date or disables the reminder.

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
NotificationManager.userNotificationCenter(_:didReceive:)
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

**Step 1 — Define the Notification.Name next to the manager:**

```swift
// CalendarReminders/Services/NotificationManager.swift
extension Notification.Name {
    /// Posted when the user taps a farm-activity notification.
    /// userInfo contains ["activityID": UUID]
    static let didTapActivityNotification = Notification.Name("didTapActivityNotification")
}
```

**Step 2 — `NotificationManager` implements `UNUserNotificationCenterDelegate`:**

```swift
extension NotificationManager {   // same class from Lesson 5.3 / 5.4

    // Show the notification banner even when the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // Called when the user taps a notification — post a deep-link event
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let idString = userInfo["activityID"] as? String,
           let activityID = UUID(uuidString: idString) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .didTapActivityNotification,
                    object: nil,
                    userInfo: ["activityID": activityID]
                )
            }
        }
        completionHandler()
    }
}
```

> Remember: `UNUserNotificationCenter.current().delegate = self` was already
> set inside `NotificationManager.init()` in Lesson 5.3 — no AppDelegate
> required.

| Delegate method | When it's called |
|-----------------|------------------|
| `willPresent` | Notification arrives while app is **in foreground** |
| `didReceive`  | User **taps** the notification                    |

**Step 3 — MainTabView switches to the Calendar tab:**

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
> `NotificationManager` does not have references to `MainTabView` or
> `CalendarTabView`. Foundation's `NotificationCenter` acts as a decoupled
> event bus:
> - **Publisher:** `NotificationManager.didReceive` posts the event
> - **Subscribers:** `MainTabView` and `CalendarTabView` each react independently
>
> This keeps the service free of SwiftUI dependencies and makes both subscribers
> testable in isolation.

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
│  NotificationManager.didReceive(response:)                   │
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
| Forget to set `delegate = self` | `didReceive` never called | Set it in `NotificationManager.init()` so it's ready before any notification arrives |
| Don't request permission | Notifications silently fail | Call `requestPermission()` when the user enables a reminder |
| Use `repeats: true` with full date | Crash — repeating triggers need partial components | Use `repeats: false` for one-time events |
| Forget `DispatchQueue.main.async` | UI update on background thread → crash | Always dispatch to main in the completion handler |
| Don't store ID in `userInfo` | Can't deep-link on tap | Always include the activity UUID |
| Forget to cancel on delete | Ghost notification fires for deleted activity | Call `cancelNotification(for:)` before `viewContext.delete` |
| Forget to cancel on complete / edit | Stale notification fires after the user finished or rescheduled the activity | Call `cancelNotification(for:)` inside the toggle handler and before re-scheduling in `EditActivityView` |
| Schedule a past date | iOS silently drops the request | Guard with `date > Date()` before building the trigger |

---

*End of Week 5 Materials - Calendar & Reminders Module*
