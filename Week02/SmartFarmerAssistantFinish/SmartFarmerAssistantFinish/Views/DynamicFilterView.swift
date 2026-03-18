//
//  DynamicFilterView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI
import CoreData

// FilteredTransactionList — used by FinanceTabView
// Handles its own delete; calls onTap so parent can open the edit sheet
struct FilteredTransactionList: View {
    @Environment(\.managedObjectContext) private var viewContext

    let viewModel: FarmViewModel
    let onTap: (Transaction) -> Void

    var fetchRequest: FetchRequest<Transaction>
    var transactions: FetchedResults<Transaction> {
        fetchRequest.wrappedValue
    }

    init(filterType: String,
         viewModel: FarmViewModel,
         onTap: @escaping (Transaction) -> Void) {
        self.viewModel = viewModel
        self.onTap = onTap

        // "all" → nil predicate (no filter, fetch everything)
        // "expense" / "income" → NSPredicate filters at database level
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
                TransactionRowView(transaction: transaction, viewModel: viewModel)
                    .onTapGesture { onTap(transaction) }
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
