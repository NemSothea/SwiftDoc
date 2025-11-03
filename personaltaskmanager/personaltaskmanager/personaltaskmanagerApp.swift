
//
//  personaltaskmanagerApp.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//

import SwiftUI
import SwiftData


@main
struct personaltaskmanagerApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            // iCloud configuration
            let schema = Schema([Task.self, Category.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.kh.com.kosign.personaltaskmanager")
            )
           

            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            
        }
        .modelContainer(modelContainer)
    }
    
    
}
