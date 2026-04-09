//
//  CalendarTabView.swift
//  SmartFarmerAssistantFinish
//
//  Calendar & Reminders Module (Project 2)
//  — Custom calendar grid with DatePicker
//  — FarmActivity scheduling
//  — Local notification support via NotificationManager
//

import SwiftUI
import CoreData
import UserNotifications

// MARK: - CalendarTabView

struct CalendarTabView: View {
    @EnvironmentObject private var viewModel: FarmViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: FarmActivity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FarmActivity.date, ascending: true)]
    ) var activities: FetchedResults<FarmActivity>

    @State private var selectedDate = Date()
    @State private var showingAddActivity = false

    private let calendar = Calendar.current

    /// Activities whose date falls on the currently selected day.
    var activitiesForSelectedDate: [FarmActivity] {
        activities.filter { activity in
            guard let date = activity.date else { return false }
            return calendar.isDate(date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ── Calendar Grid ──
                CalendarGridView(
                    selectedDate: $selectedDate,
                    activities: activities
                )
                .padding(.horizontal)
                .padding(.top, 8)

                Divider()
                    .padding(.top, 8)

                // ── Activity list for selected date ──
                List {
                    Section(header:
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("សកម្មភាព \(formattedSelectedDate)")
                        }
                    ) {
                        if activitiesForSelectedDate.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 6) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text("គ្មានសកម្មភាពសម្រាប់ថ្ងៃនេះ")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 20)
                                Spacer()
                            }
                        } else {
                            ForEach(activitiesForSelectedDate, id: \.self) { activity in
                                HStack(spacing: 12) {
                                    // Toggle button OUTSIDE NavigationLink so it gets its own tap target
                                    Button {
                                        activity.isCompleted.toggle()
                                        if activity.isCompleted, activity.reminderEnabled, let id = activity.id {
                                            NotificationManager.shared.cancelNotification(for: id)
                                        }
                                        try? activity.managedObjectContext?.save()
                                    } label: {
                                        Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(activity.isCompleted ? .green : .gray)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())

                                    NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                        ActivityRowContent(activity: activity, viewModel: viewModel)
                                    }
                                }
                            }
                            .onDelete { offsets in
                                deleteActivities(at: offsets)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
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
            // Deep-link: when a notification is tapped, jump to the activity's date
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

    // MARK: - Helpers

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "km_KH")
        return formatter.string(from: selectedDate)
    }

    private func deleteActivities(at offsets: IndexSet) {
        let toDelete = offsets.map { activitiesForSelectedDate[$0] }
        for activity in toDelete {
            // Cancel any pending notification
            if activity.reminderEnabled, let id = activity.id {
                NotificationManager.shared.cancelNotification(for: id)
            }
            viewContext.delete(activity)
        }
        try? viewContext.save()
    }
}

// MARK: - CalendarGridView
/// A month-view calendar grid with day selection and activity-dot indicators.

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let activities: FetchedResults<FarmActivity>

    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["អា", "ច", "អ", "ពុ", "ព្រ", "សុ", "ស"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 10) {

            // ── Month / Year navigation ──
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(.blue)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(monthYearString)
                        .font(.title3.bold())
                    Text(yearString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3.bold())
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 4)

            // ── Day-of-week headers ──
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // ── Day cells ──
            LazyVGrid(columns: columns, spacing: 4) {
                // Blank cells before the 1st of the month (negative IDs avoid collision with day 1…31)
                ForEach((-firstWeekdayOffset)..<0, id: \.self) { _ in
                    Color.clear
                        .frame(height: 44)
                }

                // Actual day cells
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
        // Keep displayedMonth in sync when selectedDate changes externally
        .onChange(of: selectedDate) { newDate in
            let selMonth = calendar.dateComponents([.year, .month], from: newDate)
            let dispMonth = calendar.dateComponents([.year, .month], from: displayedMonth)
            if selMonth.year != dispMonth.year || selMonth.month != dispMonth.month {
                displayedMonth = newDate
            }
        }
    }

    // MARK: - Calendar Math

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

    /// Number of blank cells before day 1 (Sunday = 0)
    private var firstWeekdayOffset: Int {
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

// MARK: - DayCellView

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

            Circle()
                .fill(hasActivities ? Color.green : Color.clear)
                .frame(width: 6, height: 6)
        }
        .frame(height: 44)
    }

    private var textColor: Color {
        if isSelected { return .white }
        if isToday { return .blue }
        return .primary
    }

    private var bgColor: Color {
        if isSelected { return .blue }
        if isToday { return Color.blue.opacity(0.15) }
        return .clear
    }
}

// MARK: - ActivityRowView

struct ActivityRowContent: View {
    let activity: FarmActivity
    let viewModel: FarmViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title ?? "")
                    .font(.headline)
                    .strikethrough(activity.isCompleted)
                    .foregroundColor(activity.isCompleted ? .gray : .primary)

                HStack(spacing: 6) {
                    Label(activity.activityType ?? "", systemImage: iconForType(activity.activityType))
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

    private func iconForType(_ type: String?) -> String {
        switch type {
        case "ដាំដំណាំ":   return "leaf.fill"
        case "ស្រោចទឹក":   return "drop.fill"
        case "បាញ់ថ្នាំ":    return "sprinkler.and.droplets"
        case "ច្រូតកាត់":   return "scissors"
        default:            return "ellipsis.circle"
        }
    }
}

// MARK: - ActivityDetailView

struct ActivityDetailView: View {
    @ObservedObject var activity: FarmActivity
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEdit = false

    var body: some View {
        Form {
            Section(header: Text("ព័ត៌មានសកម្មភាព")) {
                DetailRow(label: "ចំណងជើង", value: activity.title ?? "—")
                DetailRow(label: "ប្រភេទ", value: activity.activityType ?? "—")

                if let date = activity.date {
                    DetailRow(label: "កាលបរិច្ឆេទ", value: formatDate(date))
                    DetailRow(label: "ម៉ោង", value: formatTime(date))
                }
            }

            Section(header: Text("កំណត់ចំណាំ")) {
                Text(activity.notes?.isEmpty == false ? activity.notes! : "គ្មានកំណត់ចំណាំ")
                    .foregroundColor(activity.notes?.isEmpty == false ? .primary : .gray)
            }

            Section(header: Text("ស្ថានភាព")) {
                HStack {
                    Text("បានបញ្ចប់")
                    Spacer()
                    Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(activity.isCompleted ? .green : .red)
                }

                HStack {
                    Text("ការរំលឹក")
                    Spacer()
                    Image(systemName: activity.reminderEnabled ? "bell.fill" : "bell.slash")
                        .foregroundColor(activity.reminderEnabled ? .orange : .gray)
                }
            }

            Section {
                Button(action: {
                    activity.isCompleted.toggle()
                    if activity.isCompleted, activity.reminderEnabled, let id = activity.id {
                        NotificationManager.shared.cancelNotification(for: id)
                    }
                    try? viewContext.save()
                }) {
                    HStack {
                        Image(systemName: activity.isCompleted ? "arrow.uturn.backward" : "checkmark")
                        Text(activity.isCompleted ? "សម្គាល់ថាមិនទាន់បញ្ចប់" : "សម្គាល់ថាបានបញ្ចប់")
                    }
                    .foregroundColor(activity.isCompleted ? .orange : .green)
                }
            }
        }
        .navigationTitle(activity.title ?? "សកម្មភាព")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("កែសម្រួល") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditActivityView(activity: activity)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .long
        fmt.locale = Locale(identifier: "km_KH")
        return fmt.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}

/// A simple label–value row used inside Form sections.
private struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// MARK: - AddActivityView

struct AddActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var title = ""
    @State private var activityType = "ដាំដំណាំ"
    @State private var notes = ""
    @State private var date: Date
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var showPermissionAlert = false

    let activityTypes = ["ដាំដំណាំ", "ស្រោចទឹក", "បាញ់ថ្នាំ", "ច្រូតកាត់", "ផ្សេងៗ"]

    init(initialDate: Date = Date()) {
        _date = State(initialValue: initialDate)
        _reminderTime = State(initialValue: initialDate)
    }

    var body: some View {
        NavigationView {
            Form {
                // Activity info
                Section(header: Text("ព័ត៌មានសកម្មភាព")) {
                    TextField("ចំណងជើង", text: $title)

                    Picker("ប្រភេទ", selection: $activityType) {
                        ForEach(activityTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }

                    DatePicker(
                        "កាលបរិច្ឆេទ",
                        selection: $date,
                        displayedComponents: .date
                    )
                }

                // Notes
                Section(header: Text("កំណត់ចំណាំ")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }

                // Reminder
                Section(header: Text("ការរំលឹក")) {
                    Toggle("បើកការរំលឹក", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { enabled in
                            if enabled {
                                requestNotificationPermission()
                            }
                        }

                    if reminderEnabled {
                        DatePicker(
                            "ម៉ោងរំលឹក",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
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
            .alert(isPresented: $showPermissionAlert) {
                Alert(
                    title: Text("ការអនុញ្ញាត"),
                    message: Text("សូមបើកការជូនដំណឹងនៅក្នុង Settings ដើម្បីប្រើមុខងារការរំលឹក។"),
                    primaryButton: .default(Text("បើក Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel(Text("បោះបង់")) {
                        reminderEnabled = false
                    }
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

        // Combine selected date with reminder time
        if reminderEnabled {
            activity.date = combineDateAndTime(date: date, time: reminderTime)
        } else {
            activity.date = date
        }

        try? viewContext.save()

        // Schedule notification
        if reminderEnabled {
            NotificationManager.shared.scheduleNotification(for: activity)
        }

        presentationMode.wrappedValue.dismiss()
    }

    // MARK: - Notification Permission

    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermission { granted in
            if !granted {
                showPermissionAlert = true
            }
        }
    }

    // MARK: - Helpers

    /// Merges the date portion of one Date with the time portion of another.
    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        let dateComps = cal.dateComponents([.year, .month, .day], from: date)
        let timeComps = cal.dateComponents([.hour, .minute], from: time)
        var merged = DateComponents()
        merged.year = dateComps.year
        merged.month = dateComps.month
        merged.day = dateComps.day
        merged.hour = timeComps.hour
        merged.minute = timeComps.minute
        return cal.date(from: merged) ?? date
    }
}

// MARK: - EditActivityView

struct EditActivityView: View {
    @ObservedObject var activity: FarmActivity
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var title: String
    @State private var activityType: String
    @State private var notes: String
    @State private var date: Date
    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date
    @State private var showPermissionAlert = false

    let activityTypes = ["ដាំដំណាំ", "ស្រោចទឹក", "បាញ់ថ្នាំ", "ច្រូតកាត់", "ផ្សេងៗ"]

    init(activity: FarmActivity) {
        self.activity = activity
        _title = State(initialValue: activity.title ?? "")
        _activityType = State(initialValue: activity.activityType ?? "ដាំដំណាំ")
        _notes = State(initialValue: activity.notes ?? "")
        _date = State(initialValue: activity.date ?? Date())
        _reminderEnabled = State(initialValue: activity.reminderEnabled)
        _reminderTime = State(initialValue: activity.date ?? Date())
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

                    DatePicker(
                        "កាលបរិច្ឆេទ",
                        selection: $date,
                        displayedComponents: .date
                    )
                }

                Section(header: Text("កំណត់ចំណាំ")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }

                Section(header: Text("ការរំលឹក")) {
                    Toggle("បើកការរំលឹក", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { enabled in
                            if enabled {
                                requestNotificationPermission()
                            }
                        }

                    if reminderEnabled {
                        DatePicker(
                            "ម៉ោងរំលឹក",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
            }
            .navigationTitle("កែសម្រួលសកម្មភាព")
            .navigationBarItems(
                leading: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("រក្សាទុក") {
                    updateActivity()
                }
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
                    secondaryButton: .cancel(Text("បោះបង់")) {
                        reminderEnabled = false
                    }
                )
            }
        }
    }

    private func updateActivity() {
        // Cancel old notification first
        if let id = activity.id {
            NotificationManager.shared.cancelNotification(for: id)
        }

        activity.title = title
        activity.activityType = activityType
        activity.notes = notes
        activity.reminderEnabled = reminderEnabled

        if reminderEnabled {
            activity.date = combineDateAndTime(date: date, time: reminderTime)
            NotificationManager.shared.scheduleNotification(for: activity)
        } else {
            activity.date = date
        }

        try? viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }

    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermission { granted in
            if !granted {
                showPermissionAlert = true
            }
        }
    }

    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        let dateComps = cal.dateComponents([.year, .month, .day], from: date)
        let timeComps = cal.dateComponents([.hour, .minute], from: time)
        var merged = DateComponents()
        merged.year = dateComps.year
        merged.month = dateComps.month
        merged.day = dateComps.day
        merged.hour = timeComps.hour
        merged.minute = timeComps.minute
        return cal.date(from: merged) ?? date
    }
}
