//
//  TransactionType.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//


// Models/Transaction.swift
import Foundation
import SwiftData

enum TransactionType: String, CaseIterable {
    case expense = "ចំណាយ"      // Expense
    case income = "ចំណូល"       // Income
}

enum ExpenseCategory: String, CaseIterable {
    case seeds = "គ្រាប់ពូជ"        // Seeds
    case fertilizer = "ជី"           // Fertilizer
    case labor = "កម្លាំងពលកម្ម"    // Labor
    case tools = "ឧបករណ៍"          // Tools
    case other = "ផ្សេងៗ"           // Other
}

enum IncomeCategory: String, CaseIterable {
    case vegetable = "បន្លែ"         // Vegetables
    case fruit = "ផ្លែឈើ"           // Fruits
    case grain = "ស្រូវ-ដំណាំ"      // Grains/Crops
    case livestock = "សត្វ"          // Livestock
    case other = "ផ្សេងៗ"           // Other
}

@Model
class Transaction {
    var amount: Double
    var date: Date
    var note: String
    var type: String  // "expense" or "income"
    var category: String
    
    init(amount: Double, date: Date = Date(), note: String = "", type: String, category: String) {
        self.amount = amount
        self.date = date
        self.note = note
        self.type = type
        self.category = category
    }
    
    // Computed property for display
    var categoryName: String {
        if type == "expense" {
            return ExpenseCategory(rawValue: category)?.rawValue ?? category
        } else {
            return IncomeCategory(rawValue: category)?.rawValue ?? category
        }
    }
    
    var isExpense: Bool { type == "expense" }
    var isIncome: Bool { type == "income" }
}