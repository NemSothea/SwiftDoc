//
//  SmartFarmerAssistantFinishApp.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI
import CoreData

@main
struct SmartFarmerAssistantFinishApp: App {
    
    // Core Data Persistent Container
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmartFarmerAssistantFinish")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
