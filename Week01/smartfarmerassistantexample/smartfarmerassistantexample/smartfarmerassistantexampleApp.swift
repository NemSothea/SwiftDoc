//
//  SmartFarmerAssistantExampleApp.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//

import SwiftUI
import SwiftData

@main
struct SmartFarmerAssistantExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [
                    Transaction.self,
                    FarmActivity.self,
                    Pest.self,
                    JournalEntry.self
                ])
    }
}
