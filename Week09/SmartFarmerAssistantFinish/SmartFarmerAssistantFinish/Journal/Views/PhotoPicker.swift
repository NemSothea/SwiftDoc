// Journal/Views/PhotoPicker.swift
import SwiftUI
import UIKit

/// iOS 13+ bridge around `UIImagePickerController`.
///
/// SwiftUI doesn't ship a native picker until iOS 16's `PhotosPicker`,
/// so we wrap the UIKit controller with `UIViewControllerRepresentable`.
///
/// Usage:
///     .sheet(isPresented: $showingPicker) {
///         PhotoPicker(sourceType: .photoLibrary) { image in
///             // image is a UIImage? — nil if user cancelled
///         }
///     }
struct PhotoPicker: UIViewControllerRepresentable {

    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var onPick: (UIImage?) -> Void

    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // MARK: - Coordinator
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoPicker

        init(parent: PhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            parent.onPick(image)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onPick(nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
