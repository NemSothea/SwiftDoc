//
//  HomeView.swift
//  PestDisease
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        List {
            Section {
                Text("Identify pests and diseases by crop. All content works offline.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                NavigationLink {
                    CropListView()
                } label: {
                    Label("Browse by crop", systemImage: "leaf.fill")
                }
            }
        }
        .navigationTitle("Quick Guide")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
