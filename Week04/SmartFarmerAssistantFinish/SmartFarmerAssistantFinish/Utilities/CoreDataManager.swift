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

/// CoreDataManager is a singleton class responsible for managing the Core Data stack.
/// It provides a centralized interface for the entire app to interact with the SQLite database.
/// This includes initializing the persistent container, providing access to the managed object context,
/// and handling save operations for all data persistence tasks.
class CoreDataManager {
    /// Singleton instance - ensures only one CoreDataManager exists throughout the app lifecycle
    /// Used globally: CoreDataManager.shared.context or CoreDataManager.shared.saveContext()
    static let shared = CoreDataManager()
    
    /// Lazy-initialized NSPersistentContainer that sets up the Core Data stack.
    /// Loads the "SmartFarmerAssistantFinish.xcdatamodeld" data model and initializes the SQLite database.
    /// - Only created on first access to avoid unnecessary overhead during app startup
    /// - If persistent stores fail to load, the app will crash with a fatal error (prevents silent failures)
    /// - The persistent stores (SQLite database files) are stored in the app's Documents directory
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmartFarmerAssistantFinish")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    /// Returns the main NSManagedObjectContext used for all fetch, create, update, and delete operations.
    /// - The viewContext is the main thread context, safe to use for UI updates
    /// - All objects fetched or created through this context are automatically observed for UI binding
    /// - This context writes changes directly to the persistent container
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Persists all changes made in the managed object context to the SQLite database.
    /// - Checks if there are unsaved changes before attempting to save (optimization)
    /// - Catches and logs any save errors to prevent app crashes
    /// - Should be called after creating, updating, or deleting managed objects
    /// - Called by ViewModels when user saves transaction data
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
