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

    // Use the shared CoreDataManager — do NOT create a second container
    let context = CoreDataManager.shared.context

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, context)
        }
    }
}
