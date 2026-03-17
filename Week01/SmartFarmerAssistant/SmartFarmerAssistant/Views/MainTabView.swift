//
//  MainTabView.swift
//  SmartFarmerAssistant
//
//  Created by sothea007 on 13/3/26.
//

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
                    Label("សត្វល្អិត", systemImage: "bug")
                }
                .tag(2)
            
           
        }
        .environment(viewModel)  // Pass ViewModel to all child views
    }
}

