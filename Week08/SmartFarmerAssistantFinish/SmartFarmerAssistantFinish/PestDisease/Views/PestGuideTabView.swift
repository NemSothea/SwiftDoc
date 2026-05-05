//
//  PestGuideTabView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI
import CoreData

/// Root view for Week 6 — Pest & Disease Guide.
///
/// - Reads pests from Core Data via `@FetchRequest` (alphabetical)
/// - Filters through `PestGuideViewModel.searchText`
/// - Pushes a read-only `PestDetailView` on row tap
///
/// Data arrives via `PestDataLoader.preloadIfNeeded()` on first launch; after
/// that the module is fully offline.
struct PestGuideTabView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Pest.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pest.name, ascending: true)]
    ) private var pests: FetchedResults<Pest>

    @StateObject private var viewModel = PestGuideViewModel()

    private var displayedPests: [Pest] {
        viewModel.filter(Array(pests))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText,
                          placeholder: "ស្វែងរកឈ្មោះ រោគសញ្ញា …")

                if displayedPests.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(displayedPests, id: \.self) { pest in
                            NavigationLink(destination: PestDetailView(pest: pest)) {
                                PestRowView(pest: pest)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("មគ្គុទ្ទេសសត្វល្អិត")
        }
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text(viewModel.searchText.isEmpty
                 ? "មិនមានទិន្នន័យ — ទាញពី pests.json"
                 : "រកមិនឃើញលទ្ធផលសម្រាប់ \"\(viewModel.searchText)\"")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
}
