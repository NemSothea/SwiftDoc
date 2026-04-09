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

    // Initialize the notification manager early so it becomes the
    // UNUserNotificationCenter delegate before any notification arrives.
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, context)
                .environmentObject(notificationManager)
                .onAppear {
                    // Re-check notification authorisation every time the app foregrounds
                    notificationManager.checkAuthorization()
                }
        }
    }
}
