//
//  FarmViewModel.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//


// ViewModels/FarmViewModel.swift
import Foundation
import SwiftUI
import SwiftData

@Observable
class FarmViewModel {
    // MARK: - Properties
    var selectedTab = 0
    var isLoading = false
    var errorMessage: String?
    var transactions: [Transaction] = []
     
    // Computed properties also trigger view updates
    var totalBalance: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Sample Data for Preview
    static let preview: FarmViewModel = {
        let vm = FarmViewModel()
        // We'll add sample data next week with SwiftData
        return vm
    }()
    
    // MARK: - Helper Methods
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "៛"  // Riel symbol
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "៛0"
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "km-KH")  // Khmer locale
        return formatter.string(from: date)
    }
}
