import UIKit

enum ImageResizer {
    static let maxDimension: CGFloat = 1024
    static let jpegQuality: CGFloat = 0.85

    /// Resize the longest side of `image` to `maxDimension` (upscaling skipped)
    /// and return JPEG-encoded data.
    static func resize(_ image: UIImage, maxDimension: CGFloat = maxDimension, quality: CGFloat = jpegQuality) -> Data? {
        let fixed = image.fixedOrientation()
        let size = fixed.size
        let longest = max(size.width, size.height)

        let target: CGSize
        if longest <= maxDimension {
            target = size
        } else {
            let scale = maxDimension / longest
            target = CGSize(width: floor(size.width * scale), height: floor(size.height * scale))
        }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let output = renderer.image { _ in
            fixed.draw(in: CGRect(origin: .zero, size: target))
        }
        return output.jpegData(compressionQuality: quality)
    }
}

private extension UIImage {
    /// Normalize orientation to `.up` so downstream code sees correct width/height.
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
