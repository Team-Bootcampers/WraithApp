//
//  VehicleTowTransition.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Custom push/pop transition that flies a vehicle silhouette across the middle of the
/// screen, giving the impression that the incoming question page is being towed in behind it.
final class VehicleTowTransition: NSObject, UIViewControllerAnimatedTransitioning {

    private let operation: UINavigationController.Operation
    private let vehicle: TowVehicle

    init(operation: UINavigationController.Operation, vehicle: TowVehicle) {
        self.operation = operation
        self.vehicle = vehicle
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let width = container.bounds.width
        let isForward = operation == .push
        let duration = transitionDuration(using: transitionContext)

        container.addSubview(toView)
        toView.frame = container.bounds
        toView.transform = CGAffineTransform(translationX: isForward ? width : -width, y: 0)

        let vehicleImageView = makeVehicleImageView(isForward: isForward, containerBounds: container.bounds)
        container.addSubview(vehicleImageView)

        let travel = width / 2 + vehicleImageView.bounds.width
        vehicleImageView.transform = CGAffineTransform(translationX: isForward ? travel : -travel, y: 0)

        UIView.animate(withDuration: duration * 0.6, delay: 0, options: [.curveEaseIn]) {
            fromView.transform = CGAffineTransform(translationX: isForward ? -width * 0.25 : width * 0.25, y: 0)
            fromView.alpha = 0.92
        }

        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear]) {
            vehicleImageView.transform = CGAffineTransform(translationX: isForward ? -travel : travel, y: 0)
        }

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.25,
            options: [.curveEaseOut],
            animations: {
                toView.transform = .identity
            },
            completion: { finished in
                fromView.transform = .identity
                fromView.alpha = 1
                vehicleImageView.removeFromSuperview()
                transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
            }
        )
    }

    private func makeVehicleImageView(isForward: Bool, containerBounds: CGRect) -> UIImageView {
        let vehicleSize = vehicle.size
        var image = UIImage(named: vehicle.imageName)?.withRenderingMode(.alwaysTemplate)

        // Each silhouette's nose already points left (the flight direction for a forward/push
        // transition). Mirror it for pop so the nose leads the reverse direction of travel.
        if !isForward, let cgImage = image?.cgImage, let scale = image?.scale {
            image = UIImage(cgImage: cgImage, scale: scale, orientation: .upMirrored).withRenderingMode(.alwaysTemplate)
        }

        let imageView = UIImageView(image: image)
        imageView.tintColor = .wraithPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(
            x: (containerBounds.width - vehicleSize.width) / 2,
            y: (containerBounds.height - vehicleSize.height) / 2,
            width: vehicleSize.width,
            height: vehicleSize.height
        )
        return imageView
    }
}
