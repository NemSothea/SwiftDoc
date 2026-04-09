//
//  ContentView.swift
//  PestDisease
//
//  Created by sothea007 on 30/3/26.
//

import CoreData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                SavedListView()
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark.fill")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(GuideCatalog.shared)
}
