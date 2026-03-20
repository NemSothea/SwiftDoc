//
//  FinanceTabView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//


// Views/FinanceTabView.swift
import SwiftUI
import CoreData

struct FinanceTabView: View {

    @EnvironmentObject private var viewModel: FarmViewModel
    // FinanceCoordinator is injected by MainTabView via .environmentObject(...)
    // It owns selectedTransactionID, which drives NavigationLink in the list.
    @EnvironmentObject private var coordinator: FinanceCoordinator
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showingAddTransaction = false
    @State private var filterType = "all"

    // Fetch all transactions (for summary card totals)
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) var allTransactions: FetchedResults<Transaction>

    var totalIncome: Double {
        allTransactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        allTransactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double { totalIncome - totalExpense }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary Cards
                HStack(spacing: 12) {
                    SummaryCard(
                        title: "ចំណូល",
                        amount: totalIncome,
                        color: .green,
                        icon: "arrow.up.circle.fill"
                    )
                    SummaryCard(
                        title: "ចំណាយ",
                        amount: totalExpense,
                        color: .red,
                        icon: "arrow.down.circle.fill"
                    )
                    SummaryCard(
                        title: "សមតុល្យ",
                        amount: balance,
                        color: .blue,
                        icon: "equal.circle.fill"
                    )
                }
                .padding()

                // Filter Picker
                Picker("តម្រង", selection: $filterType) {
                    Text("ទាំងអស់").tag("all")
                    Text("ចំណូល").tag("income")
                    Text("ចំណាយ").tag("expense")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Transaction list — each row is wrapped in NavigationLink(tag:selection:)
                // Tapping a row sets coordinator.selectedTransactionID, pushing
                // TransactionDetailView onto the stack.
                FilteredTransactionList(
                    filterType: filterType,
                    viewModel: viewModel,
                    selectedTransactionID: $coordinator.selectedTransactionID
                )
                .environment(\.managedObjectContext, viewContext)
            }
            .navigationTitle("កំណត់ត្រាចំណាយចំណូល")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(viewModel)
            }
        }
    }

}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    @EnvironmentObject private var viewModel: FarmViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(viewModel.formatCurrency(amount))
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
