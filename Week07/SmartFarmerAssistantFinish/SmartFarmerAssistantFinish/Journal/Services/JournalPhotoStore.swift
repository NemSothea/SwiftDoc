// Journal/Services/JournalPhotoStore.swift
import UIKit
import CoreData

/// Tiny helper around the JournalEntry's `photos` transformable attribute.
/// The on-disk format is `[Data]` — JPEG-encoded at quality 0.8.
///
/// We keep a helper struct (instead of scattering the conversion logic
/// through views) so the view layer only ever deals with `UIImage`.
enum JournalPhotoStore {

    /// Encode a `UIImage` for storage inside a JournalEntry.
    static func encode(_ image: UIImage, quality: CGFloat = 0.8) -> Data? {
        image.jpegData(compressionQuality: quality)
    }

    /// Read the `[Data]` array out of the entity and hand back UIImages.
    static func images(for entry: JournalEntry) -> [UIImage] {
        entry.photoDatas.compactMap { UIImage(data: $0) }
    }

    /// Append a new photo to the entry and save.
    static func append(_ image: UIImage,
                       to entry: JournalEntry,
                       context: NSManagedObjectContext) {
        guard let data = encode(image) else { return }
        var list = entry.photoDatas
        list.append(data)
        entry.photos = list as NSArray
        do {
            try context.save()
        } catch {
            print("JournalPhotoStore.append failed — \(error)")
        }
    }

    /// Remove a photo at `index` and save.
    static func remove(at index: Int,
                       from entry: JournalEntry,
                       context: NSManagedObjectContext) {
        var list = entry.photoDatas
        guard list.indices.contains(index) else { return }
        list.remove(at: index)
        entry.photos = list as NSArray
        do {
            try context.save()
        } catch {
            print("JournalPhotoStore.remove failed — \(error)")
        }
    }
}
