//
//  DynamicFilterView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//
import SwiftUI

struct DynamicFilterView: View {
    @State private var filterType = "expense"
    
    var body: some View {
        VStack {
            Picker("Type", selection: $filterType) {
                Text("Expense").tag("expense")
                Text("Income").tag("income")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Dynamic fetch request based on filterType
            FilteredTransactionList(filterType: filterType)
        }
    }
}

struct FilteredTransactionList: View {
    var filterType: String
    
    // Dynamic predicate based on filterType
    var fetchRequest: FetchRequest<Transaction>
    var transactions: FetchedResults<Transaction> {
        fetchRequest.wrappedValue
    }
    
    init(filterType: String) {
        self.filterType = filterType
        self.fetchRequest = FetchRequest(
            entity: Transaction.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
            predicate: NSPredicate(format: "type == %@", filterType)
        )
    }
    
    var body: some View {
        List(transactions, id: \.self) { transaction in
            TransactionRow(transaction: transaction)
        }
    }
}
