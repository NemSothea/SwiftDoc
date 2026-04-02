//
//  SmartFarmerAssistantDefaultApp.swift
//  SmartFarmerAssistantDefault
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI

@main
struct SmartFarmerAssistantDefaultApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
