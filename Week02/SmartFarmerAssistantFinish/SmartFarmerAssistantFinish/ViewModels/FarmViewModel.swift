//
//  FarmViewModel.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//
import SwiftUI
import CoreData


class FarmViewModel : ObservableObject {
    // Core Data context
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // MARK: - CRUD Operations
    
    // Create
    func addTransaction(amount: Double, note: String, type: String, category: String) {
        let transaction = Transaction(context: context)
        transaction.amount = amount
        transaction.date = Date()
        transaction.note = note
        transaction.type = type
        transaction.category = category
        transaction.id = UUID()
        
        saveContext()
    }
    
    // Read - Usually done with @FetchRequest in views
    
    // Update
    func updateTransaction(_ transaction: Transaction,
                           amount: Double,
                           note: String,
                           type: String,
                           category: String) {
        transaction.amount = amount
        transaction.note = note
        transaction.type = type
        transaction.category = category
        saveContext()
    }
    
    // Delete
    func deleteTransaction(_ transaction: Transaction) {
        context.delete(transaction)
        saveContext()
    }
    
    // Batch Delete
    func deleteAllTransactions() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            saveContext()
        } catch {
            print("Error deleting all transactions: \(error)")
        }
    }
    
    // Save context
    private func saveContext() {
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Helper Methods
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    // Get total balance (would normally use aggregation)
    func calculateTotalBalance(transactions: FetchedResults<Transaction>) -> Double {
        var total: Double = 0
        for transaction in transactions {
            if transaction.type == "income" {
                total += transaction.amount
            } else {
                total -= transaction.amount
            }
        }
        return total
    }
}
