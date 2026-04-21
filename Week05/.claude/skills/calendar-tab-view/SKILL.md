---
name: calendar-tab-view
description: Reference guide for functions, structs, and invariants in CalendarTabView.swift (SmartFarmerAssistantFinish → CalendarReminders module). Use when the user edits, debugs, extends, or asks questions about the farm-activity calendar, the month grid, activity scheduling, activity reminders/notifications, or any screen in the CalendarReminders folder.
---

# CalendarTabView function reference

File: `SmartFarmerAssistantFinish/CalendarReminders/Views/CalendarTabView.swift`

One file, seven view types. Read this skill before making edits so you preserve the notification lifecycle and the Khmer-locale display contract.

## Module context

- Model: `CalendarReminders/Models/FarmActivity+CoreData{Class,Properties}.swift` — fields: `id: UUID?`, `title: String?`, `activityType: String?`, `date: Date?`, `notes: String?`, `isCompleted: Bool`, `reminderEnabled: Bool`. The `date` field stores **both** the scheduled day and the reminder time (merged via `combineDateAndTime`).
- Service: `CalendarReminders/Services/NotificationManager.swift` — singleton that owns `UNUserNotificationCenter`. Posts `Notification.Name.didTapActivityNotification` on tap.
- View model: `FinanceViewModel` lives in `Finance/ViewModels/`. Calendar views do **not** inject or read it — they work directly with `@FetchRequest` + `viewContext` + `NotificationManager`.

## Type map

| Struct | Role | Notes |
| --- | --- | --- |
| `CalendarTabView` | Root. Holds `@FetchRequest<FarmActivity>`, `selectedDate`, `showingAddActivity`. Listens for `.didTapActivityNotification` to jump to the tapped activity's date. | Uses `InsetGroupedListStyle` for the activity list. |
| `CalendarGridView` | Month-view grid with Sunday-first column order. Owns `displayedMonth` and keeps it in sync when `selectedDate` changes externally. | Day-of-week labels are hard-coded Khmer initials. |
| `DayCellView` | One day cell: number + activity dot. | Styling only — no state. |
| `ActivityRowContent` | List row: title, type label, time, optional bell icon. Stateless; takes only the activity. |
| `ActivityDetailView` | Read-only form showing activity info + a toggle-complete button. Opens `EditActivityView` via sheet. | Uses private `DetailRow` helper. |
| `AddActivityView` | Create flow. Default activity type `"ដាំដំណាំ"`. | On save, if `reminderEnabled`, merges day + reminder time into `date` and schedules a notification. |
| `EditActivityView` | Edit flow. Cancels any old pending notification before re-scheduling. | Mirror of `AddActivityView` but seeded from the activity. |

## Function reference

### `CalendarTabView`

- **`activitiesForSelectedDate: [FarmActivity]`** — public computed. Filters `@FetchRequest` results to the same day as `selectedDate` using `Calendar.current.isDate(_:inSameDayAs:)`. No time-zone conversion.
- **`formattedSelectedDate: String`** — private. `DateFormatter(dateStyle: .long, locale: km_KH)`. Used as section header.
- **`deleteActivities(at offsets: IndexSet)`** — private. **Must** call `NotificationManager.shared.cancelNotification(for:)` for every deleted row with `reminderEnabled == true` before `viewContext.delete`. Don't reverse this order — the Core Data object's `id` may be read after deletion otherwise.

### `CalendarGridView`

Calendar math helpers are `private` and depend only on `displayedMonth` + injected `selectedDate` / `activities`. They force-unwrap `calendar.date(from:)` and `calendar.range(of:in:for:)` — safe because `displayedMonth` is always a valid Date.

- `monthYearString: String` — `"MMMM"` formatted in `km_KH`.
- `yearString: String` — `"yyyy"` in the default locale (Gregorian year).
- `firstDayOfMonth: Date` — first moment of `displayedMonth`'s month.
- `firstWeekdayOffset: Int` — number of blank cells to render before day 1. **Sunday = 0**; change this if you switch the week start.
- `numberOfDaysInMonth: Int`.
- `dateFor(_ day: Int) -> Date?` — builds a Date for a given day-of-month within `displayedMonth`.
- `isToday(_:)`, `isSelected(_:)`, `hasActivities(on:)` — predicates used by `DayCellView` to style itself.
- `selectDay(_:)` — writes to the `@Binding var selectedDate`.
- `previousMonth()`, `nextMonth()` — shift `displayedMonth` by ±1 month.

### `DayCellView`

- `textColor: Color` — priority: selected (white) → today (blue) → primary.
- `bgColor: Color` — priority: selected (blue) → today (blue 15%) → clear.

Same priority order must be preserved if you restyle — selected state must win over today's highlight.

### `ActivityRowContent`

- `timeString(from: Date) -> String` — `"HH:mm"`, default locale.
- `iconForType(_ type: String?) -> String` — maps Khmer activity types to SF Symbols:
  - `"ដាំដំណាំ"` → `leaf.fill`
  - `"ស្រោចទឹក"` → `drop.fill`
  - `"បាញ់ថ្នាំ"` → `sprinkler.and.droplets`
  - `"ច្រូតកាត់"` → `scissors`
  - anything else → `ellipsis.circle`

Keep this in sync with `activityTypes` arrays in `AddActivityView` / `EditActivityView`.

### `ActivityDetailView`

- `formatDate(_:)` — `.long` + `km_KH`.
- `formatTime(_:)` — `"HH:mm"`.
- Toggle-complete button also cancels the notification if both `isCompleted` (after toggle) and `reminderEnabled` are true.

### `AddActivityView`

- `init(initialDate: Date = Date())` — seeds both `date` and `reminderTime` to the tapped calendar day so "Add" from a selected day doesn't silently default to today.
- `saveActivity()` — order matters:
  1. Build the `FarmActivity`, assign a fresh `UUID`.
  2. If `reminderEnabled`, set `date = combineDateAndTime(date, reminderTime)`; otherwise `date = date`.
  3. `viewContext.save()`.
  4. If `reminderEnabled`, call `NotificationManager.shared.scheduleNotification(for:)`.
- `requestNotificationPermission()` — on denial, shows an alert with a "Settings" deep-link and flips the toggle back off.
- `combineDateAndTime(date:time:)` — merges `year/month/day` from `date` with `hour/minute` from `time`. Falls back to `date` if `Calendar.current.date(from:)` returns nil.

### `EditActivityView`

- `init(activity: FarmActivity)` — seeds all state from the activity. `reminderTime` is seeded from `activity.date` (since time lives in the same field).
- `updateActivity()` — **always cancels the old notification first** (by `activity.id`), even if `reminderEnabled` stays false. This avoids stale notifications after a reminder is disabled or a date is moved.
- `requestNotificationPermission()` / `combineDateAndTime(_:_:)` — same as `AddActivityView`.

## Invariants to preserve when editing

1. **Notification lifecycle:** Any code path that changes an activity's date, toggles `reminderEnabled`, marks it completed, or deletes it **must** call `NotificationManager.shared.cancelNotification(for: id)` before mutating/deleting the activity. Existing call sites to audit if you add a new mutation path: `deleteActivities`, the complete-toggle in the row, `ActivityDetailView`'s toggle, and `EditActivityView.updateActivity`.
2. **Deep-link flow:** A tapped notification posts `.didTapActivityNotification` with `userInfo["activityID"] as? UUID`. `MainTabView` switches to the Calendar tab; `CalendarTabView.onReceive` selects the date. Don't swallow or rename this notification — `NotificationManager` posts it from the `UNUserNotificationCenterDelegate`.
3. **Date field duality:** `FarmActivity.date` is both the day and the reminder clock. When `reminderEnabled` is false, it's set to the date picker value only (midnight). When true, it's the merged date+time. Any new filter/sort that assumes midnight-only will break.
4. **Locale:** Month/weekday labels and long-form dates use `km_KH`. The day-of-week header array is hard-coded Khmer; swap both together if you ever localize further.
5. **Activity type strings:** The five Khmer literals are duplicated across `AddActivityView.activityTypes`, `EditActivityView.activityTypes`, and `ActivityRowContent.iconForType`. Changing one without the others breaks the icon mapping silently (it falls through to `ellipsis.circle`).

## When to split this file

It's 788 lines and seven views. Split when you touch more than one struct in a single change — each public view belongs in its own file inside `CalendarReminders/Views/`, with `DayCellView` and `DetailRow` staying next to their parent. Don't split just to split; split when it reduces diff scope.
