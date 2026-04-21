//
//  DynamicFilterView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI
import CoreData

// FilteredTransactionList — used by FinanceTabView
//
// Week 3 change: replaced the onTap callback with NavigationLink(tag:selection:).
// Each row now pushes TransactionDetailView directly via the navigation stack.
// The selectedTransactionID binding is owned by FinanceCoordinator, so setting
// it from anywhere (e.g. a deep-link button in MainTabView) will activate
// the matching NavigationLink automatically.
struct FilteredTransactionList: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Binding to FinanceCoordinator.selectedTransactionID —
    // setting this drives programmatic navigation (deep linking)
    @Binding var selectedTransactionID: UUID?

    var fetchRequest: FetchRequest<Transaction>
    var transactions: FetchedResults<Transaction> {
        fetchRequest.wrappedValue
    }

    init(filterType: String,
         selectedTransactionID: Binding<UUID?>) {
        self._selectedTransactionID = selectedTransactionID

        // "all" → nil predicate (fetch everything)
        // "expense" / "income" → database-level filter via NSPredicate
        let predicate: NSPredicate? = filterType == "all"
            ? nil
            : NSPredicate(format: "type == %@", filterType)

        self.fetchRequest = FetchRequest(
            entity: Transaction.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
            predicate: predicate
        )
    }

    var body: some View {
        List {
            ForEach(transactions, id: \.self) { transaction in
                // NavigationLink(tag:selection:) — when selectedTransactionID
                // equals transaction.id this link activates, pushing the detail view.
                // Tapping the row sets selectedTransactionID via the binding.
                NavigationLink(
                    destination: TransactionDetailView(transaction: transaction),
                    tag: transaction.id ?? UUID(),
                    selection: $selectedTransactionID
                ) {
                    TransactionRowView(transaction: transaction)
                }
            }
            .onDelete(perform: deleteTransactions)
        }
    }

    private func deleteTransactions(offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(transactions[index])
        }
        try? viewContext.save()
    }
}
