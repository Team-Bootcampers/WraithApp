//
//  VoyaLogoView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Circular compass-needle emblem used as the Voya wordmark logo.
final class VoyaLogoView: UIView {

    private let badgeLayer = CAGradientLayer()
    private let needleTipLayer = CAShapeLayer()
    private let needleTailLayer = CAShapeLayer()
    private let centerDotLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        badgeLayer.colors = [UIColor.wraithPrimary.cgColor, UIColor.wraithSecondary.cgColor]
        badgeLayer.startPoint = CGPoint(x: 0.15, y: 0.1)
        badgeLayer.endPoint = CGPoint(x: 0.9, y: 0.95)
        layer.addSublayer(badgeLayer)
        layer.addSublayer(needleTailLayer)
        layer.addSublayer(needleTipLayer)
        layer.addSublayer(centerDotLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let side = min(bounds.width, bounds.height)
        badgeLayer.frame = bounds
        badgeLayer.cornerRadius = side / 2
        badgeLayer.masksToBounds = true

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let (tipPath, tailPath) = Self.needlePaths(center: center, side: side, rotation: .pi / 4)

        needleTipLayer.path = tipPath.cgPath
        needleTipLayer.fillColor = UIColor.wraithOnPrimary.cgColor

        needleTailLayer.path = tailPath.cgPath
        needleTailLayer.fillColor = UIColor.wraithOnPrimary.withAlphaComponent(0.45).cgColor

        let dotRadius = side * 0.05
        centerDotLayer.path = UIBezierPath(
            arcCenter: center,
            radius: dotRadius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        ).cgPath
        centerDotLayer.fillColor = UIColor.wraithOnSurface.cgColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        badgeLayer.colors = [UIColor.wraithPrimary.cgColor, UIColor.wraithSecondary.cgColor]
        setNeedsLayout()
    }

    /// Builds a two-toned compass-needle kite (bright tip triangle / muted tail triangle) rotated to point northeast.
    private static func needlePaths(center: CGPoint, side: CGFloat, rotation: CGFloat) -> (tip: UIBezierPath, tail: UIBezierPath) {
        let length = side * 0.32
        let width = side * 0.14

        func rotated(_ point: CGPoint) -> CGPoint {
            let cosA = cos(rotation)
            let sinA = sin(rotation)
            return CGPoint(
                x: center.x + point.x * cosA - point.y * sinA,
                y: center.y + point.x * sinA + point.y * cosA
            )
        }

        let tip = rotated(CGPoint(x: 0, y: -length))
        let tail = rotated(CGPoint(x: 0, y: length))
        let left = rotated(CGPoint(x: -width, y: 0))
        let right = rotated(CGPoint(x: width, y: 0))

        let tipPath = UIBezierPath()
        tipPath.move(to: tip)
        tipPath.addLine(to: right)
        tipPath.addLine(to: left)
        tipPath.close()

        let tailPath = UIBezierPath()
        tailPath.move(to: tail)
        tailPath.addLine(to: left)
        tailPath.addLine(to: right)
        tailPath.close()

        return (tipPath, tailPath)
    }
}
