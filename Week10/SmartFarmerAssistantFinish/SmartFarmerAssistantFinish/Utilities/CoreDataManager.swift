//
//  CoreDataManager.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//


// Utilities/CoreDataManager.swift
import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // Reference to AppDelegate's persistent container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmartFarmerAssistantFinish")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Save context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
