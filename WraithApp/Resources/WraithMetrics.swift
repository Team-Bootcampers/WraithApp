//
//  WraithMetrics.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import CoreGraphics

/// Shared spacing scale (margins, gaps, offsets). Every layout constant used across
/// the app's views should come from here instead of being written inline.
enum WraithSpacing {
    static let space4: CGFloat = 4
    static let space6: CGFloat = 6
    static let space8: CGFloat = 8
    static let space10: CGFloat = 10
    static let space12: CGFloat = 12
    static let space14: CGFloat = 14
    static let space16: CGFloat = 16
    static let space18: CGFloat = 18
    static let space20: CGFloat = 20
    static let space24: CGFloat = 24
    static let space28: CGFloat = 28
    static let space32: CGFloat = 32
    static let space40: CGFloat = 40
    static let space60: CGFloat = 60
    static let space80: CGFloat = 80
    static let space140: CGFloat = 140
    static let space200: CGFloat = 200
    static let space220: CGFloat = 220
    static let space280: CGFloat = 280
    static let space320: CGFloat = 320
}

/// Shared corner radius scale.
enum WraithRadius {
    static let radius2: CGFloat = 2
    static let radius3: CGFloat = 3
    static let radius5: CGFloat = 5
    static let radius11: CGFloat = 11
    static let radius12: CGFloat = 12
    static let radius16: CGFloat = 16
    static let radius18: CGFloat = 18
    static let radius24: CGFloat = 24
    static let radius28: CGFloat = 28
    static let radius38: CGFloat = 38
}

/// Shared border/stroke widths.
enum WraithBorderWidth {
    static let hairline: CGFloat = 1
    static let emphasized: CGFloat = 1.5
    static let selected: CGFloat = 2
}
