//
//  PestRowView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI

struct PestRowView: View {
    @ObservedObject var pest: Pest

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.12))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(khmerName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if let en = englishName {
                    Text(en)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if let kh = khmerType {
                    Text(kh)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if pest.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let asset = pest.imageName,
           !asset.isEmpty,
           UIImage(named: asset) != nil {
            Image(asset)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Image(systemName: "ladybug.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
    }

    // MARK: - Name splitting (Khmer vs English)

    private var khmerName: String {
        guard let name = pest.name, !name.isEmpty else { return "" }
        if let paren = name.firstIndex(of: "(") {
            return name[..<paren].trimmingCharacters(in: CharacterSet.whitespaces)
        }
        return name
    }

    private var englishName: String? {
        guard let name = pest.name,
              let start = name.firstIndex(of: "("),
              let end = name.lastIndex(of: ")"),
              start < end else { return nil }
        let inside = name[name.index(after: start)..<end]
        let text = inside.trimmingCharacters(in: CharacterSet.whitespaces)
        return text.isEmpty ? nil : text
    }

    private var khmerType: String? {
        guard let type = pest.pestType, !type.isEmpty else { return nil }
        if let slash = type.firstIndex(of: "/") {
            let part = type[..<slash].trimmingCharacters(in: CharacterSet.whitespaces)
            return part.isEmpty ? nil : part
        }
        return type
    }
}
