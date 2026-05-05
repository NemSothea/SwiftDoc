//
//  TransactionListView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//


import SwiftUI
import CoreData

struct TransactionListView: View {
    // Automatically fetches and watches for changes
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) var transactions: FetchedResults<Transaction>
    
    // Filtered fetch request
    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "type == %@", "expense")
    ) var expenses: FetchedResults<Transaction>
    
    var body: some View {
        List {
            ForEach(transactions, id: \.self) { transaction in
                VStack(alignment: .leading) {
                    Text(transaction.note ?? "No note")
                        .font(.headline)
                    Text("Amount: \(transaction.amount)")
                        .font(.subheadline)
                }
            }
        }
    }
}
