//
//  ContentView.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//

import SwiftUI

struct ContentView: View {
    // @State for local view state
    @State private var viewModel = FarmViewModel()
    
    var body: some View {
        VStack {
            Text("Balance: $\(viewModel.totalBalance)")
            
            // Bind directly to properties
            Picker("Tab", selection: Bindable(viewModel).selectedTab) {
                Text("Finance").tag(0)
                Text("Calendar").tag(1)
            }
        }
    }
}


