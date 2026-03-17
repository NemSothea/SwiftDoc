//
//  FinanceTabView.swift
//  SmartFarmerAssistant
//
//  Created by sothea007 on 13/3/26.
//
import SwiftUI

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

