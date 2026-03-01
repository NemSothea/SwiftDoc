//
//  TODOLISTApp.swift
//  TODOLIST
//
//  Created by sothea007 on 25/1/26.
//

import SwiftUI

@main
struct TODOLISTApp: App {
    
    @StateObject private var store = TaskStore()
    
    var body: some Scene {
        WindowGroup {
            Views_ContentView()
                .environmentObject(store)
        }
    }
}
