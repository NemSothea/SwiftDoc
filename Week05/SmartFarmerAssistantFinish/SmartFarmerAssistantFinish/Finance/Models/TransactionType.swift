//
//  TransactionType.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//


// Models/Transaction.swift
import Foundation

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


