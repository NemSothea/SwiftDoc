//
//  MainTabView.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//


// Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @State private var viewModel = FarmViewModel()
    
    var body: some View {
        TabView(selection: Bindable(viewModel).selectedTab) {
            FinanceTabView()
                .tabItem {
                    Label("ហិរញ្ញវត្ថុ", systemImage: "dollarsign.circle")
                }
                .tag(0)
            
            CalendarTabView()
                .tabItem {
                    Label("ប្រតិទិន", systemImage: "calendar")
                }
                .tag(1)
            
            PestGuideTabView()
                .tabItem {
                    Label("សត្វល្អិត", systemImage: "ladybug")
                }
                .tag(2)
            
            JournalTabView()
                .tabItem {
                    Label("កំណត់ហេតុ", systemImage: "book")
                }
                .tag(3)
        }
        .environment(viewModel)  // Pass ViewModel to all child views
    }
}

// Placeholder Views for each tab
struct FinanceTabView: View {
    @Environment(FarmViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            List {
                Text("Finance Tab - Coming Soon")
                Text("Total: \(viewModel.formatCurrency(0))")
            }
            .navigationTitle("កំណត់ត្រាចំណាយចំណូល")
        }
    }
}

struct CalendarTabView: View {
    var body: some View {
        NavigationStack {
            Text("Calendar Tab - Coming Soon")
                .navigationTitle("ប្រតិទិនដាំដំណាំ")
        }
    }
}

struct PestGuideTabView: View {
    var body: some View {
        NavigationStack {
            Text("Pest Guide Tab - Coming Soon")
                .navigationTitle("មគ្គុទេសក៍សត្វល្អិត")
        }
    }
}

struct JournalTabView: View {
    var body: some View {
        NavigationStack {
            Text("Journal Tab - Coming Soon")
                .navigationTitle("កំណត់ហេតុប្រចាំថ្ងៃ")
        }
    }
}
