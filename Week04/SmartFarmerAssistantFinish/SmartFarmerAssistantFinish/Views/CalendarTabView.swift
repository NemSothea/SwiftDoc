//
//  CalendarTabView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI
import CoreData

struct CalendarTabView: View {
    @EnvironmentObject private var viewModel: FarmViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: FarmActivity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FarmActivity.date, ascending: true)]
    ) var activities: FetchedResults<FarmActivity>

    @State private var showingAddActivity = false

    var body: some View {
        NavigationView {
            List {
                ForEach(activities, id: \.self) { activity in
                    ActivityRowView(activity: activity, viewModel: viewModel)
                }
                .onDelete(perform: deleteActivities)
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
                AddActivityView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(viewModel)
            }
        }
    }

    private func deleteActivities(offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(activities[index])
        }
        try? viewContext.save()
    }
}

struct ActivityRowView: View {
    let activity: FarmActivity
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

struct AddActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var title = ""
    @State private var activityType = "ដាំដំណាំ"
    @State private var notes = ""
    @State private var date = Date()
    @State private var reminderEnabled = false

    let activityTypes = ["ដាំដំណាំ", "ស្រោចទឹក", "បាញ់ថ្នាំ", "ច្រូតកាត់", "ផ្សេងៗ"]

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

                    DatePicker("កាលបរិច្ឆេទ", selection: $date, displayedComponents: .date)
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
        presentationMode.wrappedValue.dismiss()
    }
}
