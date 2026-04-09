//
//  TransactionDetailView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

// Views/TransactionDetailView.swift
// Destination view pushed when a transaction row is tapped.
// Displays full transaction details; the "កែប្រែ" (Edit) button
// opens EditTransactionView as a sheet.
import SwiftUI
import CoreData

struct TransactionDetailView: View {
    @EnvironmentObject private var viewModel: FarmViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var transaction: Transaction

    @State private var showingEdit = false

    var body: some View {
        Form {
            // Amount
            Section(header: Text("ចំនួនទឹកប្រាក់")) {
                HStack {
                    Text(viewModel.formatCurrency(transaction.amount))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(transaction.isExpense ? .red : .green)
                    Spacer()
                    Image(systemName: transaction.isExpense
                          ? "arrow.down.circle.fill"
                          : "arrow.up.circle.fill")
                        .foregroundColor(transaction.isExpense ? .red : .green)
                        .font(.title2)
                }
            }

            // Type & Category
            Section(header: Text("ប្រភេទ")) {
                DetailRow(label: "ប្រភេទ",
                          value: transaction.isExpense ? "ចំណាយ" : "ចំណូល")
                DetailRow(label: "ប្រភេទរង",
                          value: transaction.categoryName)
            }

            // Note (shown only when non-empty)
            if let note = transaction.note, !note.isEmpty {
                Section(header: Text("កំណត់ចំណាំ")) {
                    Text(note)
                }
            }

            // Date
            Section(header: Text("កាលបរិច្ឆេទ")) {
                if let date = transaction.date {
                    DetailRow(label: "ថ្ងៃខែឆ្នាំ",
                              value: viewModel.formatDate(date))
                }
            }
        }
        .navigationTitle("ព័ត៌មានប្រតិបត្តិការ")
        .navigationBarItems(
            trailing: Button("កែប្រែ") {
                showingEdit = true
            }
        )
        .sheet(isPresented: $showingEdit) {
            EditTransactionView(transaction: transaction)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Helper

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
        }
    }
}
