//
//  PestDetailView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI

/// Read-only detail screen. Each section (Symptoms, Treatment, Prevention)
/// lives inside an `ExpandableSection`; tapping the header toggles `@State`
/// locally so the sections open/close independently.
struct PestDetailView: View {
    @ObservedObject var pest: Pest

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                if let credit = pest.photoCredit,
                   !credit.isEmpty,
                   hasImage {
                    Text(credit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 4) {
                    titleBlock
                    symptomsSection
                    treatmentSection
                    preventionSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(khmerName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    pest.isFavorite.toggle()
                    try? pest.managedObjectContext?.save()
                } label: {
                    Image(systemName: pest.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
    }

    // MARK: - Derived

    private var hasImage: Bool {
        guard let asset = pest.imageName, !asset.isEmpty else { return false }
        return UIImage(named: asset) != nil
    }

    /// Splits "Khmer (English)" into the Khmer part (before the first "(").
    /// Falls back to the full string if no parenthesis.
    private var khmerName: String {
        guard let name = pest.name, !name.isEmpty else { return "" }
        if let paren = name.firstIndex(of: "(") {
            return name[..<paren].trimmingCharacters(in: CharacterSet.whitespaces)
        }
        return name
    }

    /// English part inside the parentheses, or nil if the name has none.
    private var englishName: String? {
        guard let name = pest.name,
              let start = name.firstIndex(of: "("),
              let end = name.lastIndex(of: ")"),
              start < end else { return nil }
        let inside = name[name.index(after: start)..<end]
        let text = inside.trimmingCharacters(in: CharacterSet.whitespaces)
        return text.isEmpty ? nil : text
    }

    /// Splits "Khmer / English" pestType into its Khmer half.
    private var khmerType: String? {
        guard let type = pest.pestType, !type.isEmpty else { return nil }
        if let slash = type.firstIndex(of: "/") {
            let part = type[..<slash].trimmingCharacters(in: CharacterSet.whitespaces)
            return part.isEmpty ? nil : part
        }
        return type
    }

    /// English half after the "/" separator, or nil.
    private var englishType: String? {
        guard let type = pest.pestType,
              let slash = type.firstIndex(of: "/") else { return nil }
        let part = type[type.index(after: slash)...].trimmingCharacters(in: CharacterSet.whitespaces)
        return part.isEmpty ? nil : part
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        if let asset = pest.imageName, hasImage {
            Image(asset)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
        } else {
            ZStack {
                Color.green.opacity(0.12)
                Image(systemName: "ladybug.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
        }
    }

    // MARK: - Title block

    @ViewBuilder
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(khmerName)
                .font(.title2.bold())
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
            if let en = englishName {
                Text(en)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            if let kh = khmerType {
                Text(kh)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 6)
            }
            if let en = englishType {
                Text(en)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Sections

    private var symptomsSection: some View {
        ExpandableSection(title: "រោគសញ្ញា", icon: "stethoscope") {
            sectionBody(pest.symptoms)
        }
    }

    private var treatmentSection: some View {
        ExpandableSection(title: "វិធីព្យាបាល", icon: "cross.case") {
            sectionBody(pest.treatment)
        }
    }

    @ViewBuilder
    private var preventionSection: some View {
        if let prevention = pest.prevention, !prevention.isEmpty {
            ExpandableSection(title: "វិធីការពារ",
                              icon: "shield.lefthalf.filled",
                              initiallyExpanded: false) {
                sectionBody(prevention)
            }
        }
    }

    private func sectionBody(_ text: String?) -> some View {
        Text(text ?? "—")
            .font(.body)
            .foregroundColor(.primary)
            .lineSpacing(5)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
