//
//  MainTabView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//


// Views/MainTabView.swift (Week 8 — Dashboard + Navigation Coordinator)
import SwiftUI
import CoreData

struct MainTabView: View {
    @StateObject private var viewModel: FinanceViewModel
    // FinanceCoordinator is created here (root owner) and injected
    // into the entire view hierarchy via .environmentObject(financeCoordinator).
    // Any view can then trigger Finance tab navigation by mutating
    // financeCoordinator.selectedTransactionID.
    @StateObject private var financeCoordinator = FinanceCoordinator()
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var viewContext

    init() {
        _viewModel = StateObject(wrappedValue: FinanceViewModel(context: CoreDataManager.shared.context))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardTabView()
                .tabItem {
                    Label("ផ្ទាំងគ្រប់គ្រង", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)
                .environment(\.managedObjectContext, viewContext)

            FinanceTabView()
                .tabItem {
                    Label("ហិរញ្ញវត្ថុ", systemImage: "dollarsign.circle")
                }
                .tag(1)
                .environment(\.managedObjectContext, viewContext)

            CalendarTabView()
                .tabItem {
                    Label("ប្រតិទិន", systemImage: "calendar")
                }
                .tag(2)
                .environment(\.managedObjectContext, viewContext)

            PestGuideTabView()
                .tabItem {
                    Label("សត្វល្អិត", systemImage: "ladybug")
                }
                .tag(3)
                .environment(\.managedObjectContext, viewContext)

            JournalTabView()
                .tabItem {
                    Label("កំណត់ហេតុ", systemImage: "book")
                }
                .tag(4)
                .environment(\.managedObjectContext, viewContext)
        }
        .environmentObject(viewModel)
        // Inject the coordinator so FinanceTabView and its children can access it
        .environmentObject(financeCoordinator)
        // When a notification is tapped, switch to the Calendar tab (now tag 2).
        // CalendarTabView also listens and will select the correct date.
        .onReceive(
            NotificationCenter.default.publisher(for: .didTapActivityNotification)
        ) { _ in
            selectedTab = 2
        }
    }

    // MARK: - Deep Link Helper
    // Call this from anywhere to jump directly to a specific transaction.
    //   1. Switch to the Finance tab (tag 1)
    //   2. Set coordinator.selectedTransactionID → NavigationLink activates
    func deepLink(to transactionID: UUID) {
        selectedTab = 1
        financeCoordinator.selectedTransactionID = transactionID
    }
}
