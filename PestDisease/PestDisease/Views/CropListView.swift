//
//  CropListView.swift
//  PestDisease
//

import SwiftUI

struct CropListView: View {
    @EnvironmentObject private var catalog: GuideCatalog

    var body: some View {
        Group {
            if catalog.crops.isEmpty {
                ContentUnavailableView(
                    "No crops",
                    systemImage: "tray",
                    description: Text("Add crops to guide.json in the app bundle.")
                )
            } else {
                List(catalog.crops) { crop in
                    NavigationLink(value: crop) {
                        Text(crop.name)
                        .font(.body)
                    }
                }
            }
        }
        .navigationTitle("Crops")
        .navigationDestination(for: GuideCrop.self) { crop in
            ProblemListView(crop: crop)
        }
    }
}
