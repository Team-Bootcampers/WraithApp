//
//  TowVehicle.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// A vehicle silhouette used by `VehicleTowTransition`. Each artwork already faces left
/// in its base orientation, matching the direction of a forward/push transition.
enum TowVehicle: CaseIterable {
    case plane
    case ship
    case train

    var imageName: String {
        switch self {
        case .plane: return "PlaneSilhouette"
        case .ship: return "ShipSilhouette"
        case .train: return "TrainSilhouette"
        }
    }

    var size: CGSize {
        switch self {
        case .plane: return CGSize(width: 240, height: 168)
        case .ship: return CGSize(width: 140, height: 47)
        case .train: return CGSize(width: 190, height: 46)
        }
    }
}
