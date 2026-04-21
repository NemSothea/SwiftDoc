//
//  PestGuideTabView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI
import CoreData

struct PestGuideTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Pest.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pest.name, ascending: true)]
    ) var pests: FetchedResults<Pest>

    @State private var showingAddPest = false
    @State private var searchText = ""

    var displayedPests: [Pest] {
        if searchText.isEmpty {
            return Array(pests)
        }
        return pests.filter {
            ($0.name ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.pestType ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(displayedPests, id: \.self) { pest in
                    NavigationLink(destination: PestDetailView(pest: pest)) {
                        PestRowView(pest: pest)
                    }
                }
                .onDelete(perform: deletePests)
            }
            .navigationTitle("មគ្គុទ្ទេសសត្វល្អិត")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPest = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPest) {
                AddPestView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deletePests(offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(displayedPests[index])
        }
        try? viewContext.save()
    }
}

struct PestRowView: View {
    let pest: Pest

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "ant.fill")
                .foregroundColor(.red)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(pest.name ?? "")
                    .font(.headline)
                Text(pest.pestType ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            if pest.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PestDetailView: View {
    let pest: Pest

    var body: some View {
        List {
            Section(header: Text("ប្រភេទ")) {
                Text(pest.pestType ?? "")
            }

            Section(header: Text("រោគសញ្ញា")) {
                Text(pest.symptoms ?? "")
            }

            Section(header: Text("វិធីព្យាបាល")) {
                Text(pest.treatment ?? "")
            }

            Section(header: Text("វិធីការពារ")) {
                Text(pest.prevention ?? "")
            }
        }
        .navigationTitle(pest.name ?? "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    pest.isFavorite.toggle()
                    try? pest.managedObjectContext?.save()
                }) {
                    Image(systemName: pest.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}

struct AddPestView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var pestType = "សត្វល្អិត"
    @State private var symptoms = ""
    @State private var treatment = ""
    @State private var prevention = ""

    let pestTypes = ["សត្វល្អិត", "ផ្សិត", "បាក់តេរី", "វីរុស", "ផ្សេងៗ"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ព័ត៌មានទូទៅ")) {
                    TextField("ឈ្មោះ", text: $name)

                    Picker("ប្រភេទ", selection: $pestType) {
                        ForEach(pestTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }

                Section(header: Text("រោគសញ្ញា")) {
                    TextField("ពិពណ៌នារោគសញ្ញា...", text: $symptoms)
                }

                Section(header: Text("វិធីព្យាបាល")) {
                    TextField("ពិពណ៌នាវិធីព្យាបាល...", text: $treatment)
                }

                Section(header: Text("វិធីការពារ")) {
                    TextField("ពិពណ៌នាវិធីការពារ...", text: $prevention)
                }
            }
            .navigationTitle("បន្ថែមសត្វល្អិត")
            .navigationBarItems(
                leading: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("រក្សាទុក") {
                    savePest()
                }
                .disabled(name.isEmpty)
            )
        }
    }

    private func savePest() {
        let pest = Pest(context: viewContext)
        pest.id = UUID()
        pest.name = name
        pest.pestType = pestType
        pest.symptoms = symptoms
        pest.treatment = treatment
        pest.prevention = prevention
        pest.isFavorite = false

        try? viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}
