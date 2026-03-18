//
//  MainTabView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//


// Views/MainTabView.swift (Updated)
import SwiftUI
import CoreData

struct MainTabView: View {
    @StateObject private var viewModel: FarmViewModel
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var viewContext

    init() {
        // Initialize viewModel with context
        _viewModel = StateObject(wrappedValue: FarmViewModel(context: CoreDataManager.shared.context))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
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
                    Label("សត្វល្អិត", systemImage: "ladybug")
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
        .environmentObject(viewModel)
    }
}
