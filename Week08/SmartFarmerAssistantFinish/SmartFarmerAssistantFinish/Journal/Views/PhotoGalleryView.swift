// Journal/Views/PhotoGalleryView.swift
import SwiftUI

/// Horizontal scrolling strip of square thumbnails.
/// Tapping a thumbnail shows the full-size image in a sheet.
struct PhotoGalleryView: View {
    let images: [UIImage]
    var thumbnailSize: CGFloat = 96

    @State private var fullscreen: IndexedImage? = nil

    var body: some View {
        if images.isEmpty {
            emptyState
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                        Button {
                            fullscreen = IndexedImage(index: idx, image: img)
                        } label: {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: thumbnailSize, height: thumbnailSize)
                                .clipped()
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 4)
            }
            .sheet(item: $fullscreen) { indexed in
                FullscreenPhotoView(image: indexed.image)
            }
        }
    }

    private var emptyState: some View {
        HStack(spacing: 8) {
            Image(systemName: "photo.on.rectangle")
                .foregroundColor(.gray)
            Text("គ្មានរូបភាព")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: thumbnailSize)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

private struct IndexedImage: Identifiable {
    let index: Int
    let image: UIImage
    var id: Int { index }
}

private struct FullscreenPhotoView: View {
    let image: UIImage
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .navigationBarItems(trailing: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}
