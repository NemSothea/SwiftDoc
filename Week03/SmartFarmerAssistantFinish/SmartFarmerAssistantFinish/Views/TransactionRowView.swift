//
//  TransactionRowView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//


// Views/TransactionRowView.swift
import SwiftUI

struct TransactionRowView: View {
    
    @ObservedObject var transaction: Transaction
    let viewModel: FarmViewModel
    
    var body: some View {
        HStack {
            // Category Icon
            Circle()
                .fill(transaction.isExpense ? Color.red : Color.green)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: transaction.isExpense ? "arrow.down" : "arrow.up")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.categoryName)
                    .font(.headline)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let date = transaction.date {
                    Text(viewModel.formatDate(date))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text(viewModel.formatCurrency(transaction.amount))
                .font(.headline)
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}
