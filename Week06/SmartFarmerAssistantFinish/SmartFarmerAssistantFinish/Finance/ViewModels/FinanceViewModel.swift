//
//  FinanceViewModel.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//
import SwiftUI
import CoreData


class FinanceViewModel : ObservableObject {
    // Core Data context
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    // MARK: - CRUD Operations
    //
    // Note: create + delete happen directly against @Environment(\.managedObjectContext)
    // in the views (e.g. AddTransactionView, the List's .onDelete). Keeping the VM
    // focused on operations that genuinely warrant a wrapper.

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

    // Save context
    private func saveContext() {
        CoreDataManager.shared.saveContext()
    }
}
