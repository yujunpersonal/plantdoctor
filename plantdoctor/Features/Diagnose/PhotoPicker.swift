import PhotosUI
import SwiftUI

struct PhotoPickerSheet: View {
    @Binding var selection: PhotosPickerItem?
    let onPicked: (UIImage) -> Void

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images, photoLibrary: .shared()) {
            Label(L10n.Home.chooseFromLibrary, systemImage: "photo.on.rectangle")
        }
        .onChange(of: selection) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { onPicked(image) }
                }
            }
        }
    }
}
