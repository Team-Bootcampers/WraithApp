//
//  POIDisplayItem.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct POIDisplayItem {
    let id: String
    let name: String
    let rating: Double
    let priceText: String?
    let imageURL: URL?
    let isSelected: Bool
    /// When set (and `isSelected` is true), the card shows a green "confirmed" border instead
    /// of the normal selection color, plus this text as a caption below the price — used for
    /// an already-purchased hotel rather than an in-progress selection.
    let confirmationText: String?

    init(id: String, name: String, rating: Double, priceText: String?, imageURL: URL?, isSelected: Bool, confirmationText: String? = nil) {
        self.id = id
        self.name = name
        self.rating = rating
        self.priceText = priceText
        self.imageURL = imageURL
        self.isSelected = isSelected
        self.confirmationText = confirmationText
    }
}
