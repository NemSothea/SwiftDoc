//
//  PestDiseaseApp.swift
//  PestDisease
//
//  Created by sothea007 on 30/3/26.
//

import SwiftUI
import CoreData

@main
struct PestDiseaseApp: App {
    private let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(GuideCatalog.shared)
        }
    }
}
