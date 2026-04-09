//
//  MainTabView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//


// Views/MainTabView.swift (Week 3 — Navigation Coordinator)
import SwiftUI
import CoreData

struct MainTabView: View {
    @StateObject private var viewModel: FarmViewModel
    // FinanceCoordinator is created here (root owner) and injected
    // into the entire view hierarchy via .environmentObject(financeCoordinator).
    // Any view can then trigger Finance tab navigation by mutating
    // financeCoordinator.selectedTransactionID.
    @StateObject private var financeCoordinator = FinanceCoordinator()
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var viewContext

    init() {
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
        // Inject the coordinator so FinanceTabView and its children can access it
        .environmentObject(financeCoordinator)
        // When a notification is tapped, switch to the Calendar tab.
        // CalendarTabView also listens and will select the correct date.
        .onReceive(
            NotificationCenter.default.publisher(for: .didTapActivityNotification)
        ) { _ in
            selectedTab = 1
        }
    }

    // MARK: - Deep Link Helper
    // Call this from anywhere to jump directly to a specific transaction.
    //   1. Switch to the Finance tab
    //   2. Set coordinator.selectedTransactionID → NavigationLink activates
    //
    // Example usage from a notification handler:
    //   mainTabView.deepLink(to: someTransactionID)
    func deepLink(to transactionID: UUID) {
        selectedTab = 0
        financeCoordinator.selectedTransactionID = transactionID
    }
}
