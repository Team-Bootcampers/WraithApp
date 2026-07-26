//
//  ImageLoader.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func loadImage(from url: URL) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}

private enum AssociatedKeys {
    static var currentImageURL: UInt8 = 0
}

extension UIImageView {

    private var currentImageURL: URL? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.currentImageURL) as? URL }
        set { objc_setAssociatedObject(self, &AssociatedKeys.currentImageURL, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }

    func setImage(from url: URL?) {
        guard currentImageURL != url else { return }
        currentImageURL = url
        image = nil

        guard let url else { return }

        Task { [weak self] in
            guard let loadedImage = try? await ImageLoader.shared.loadImage(from: url) else { return }
            await MainActor.run {
                guard let self, self.currentImageURL == url else { return }
                // A network image landing on top of the placeholder fill with no transition
                // reads as a glitch — this crossfade makes every photo in the app (cards,
                // carousels, hero images) settle in smoothly instead of popping in.
                UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) {
                    self.image = loadedImage
                }
            }
        }
    }
}
