//
//  TripPlanPDFGenerator.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Renders a `/ai/trip-planning` response into a themed, printable PDF: a gradient cover
/// page, a budget overview with proportional bars, then a section per stop with day-by-day,
/// hour-by-hour timeline cards. PDFs can't follow the app's dark-mode-aware color tokens, so
/// colors here are resolved to their fixed light-appearance hex values.
final class TripPlanPDFGenerator {

    private enum Metric {
        static let pageSize = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        static let margin: CGFloat = 40
    }

    private enum Palette {
        static let primary = UIColor(hex: "#E63946")
        static let primaryDark = UIColor(hex: "#B3212C")
        static let secondary = UIColor(hex: "#FFC145")
        static let onSurface = UIColor(hex: "#2B2118")
        static let onSurfaceVariant = UIColor(hex: "#7A6F63")
        static let surfaceVariant = UIColor(hex: "#FFF3D6")
        static let outlineVariant = UIColor(hex: "#F0E4C8")
    }

    private var cursorY: CGFloat = 0
    private var pageNumber = 0
    private var context: UIGraphicsPDFRendererContext!

    func renderPDF(response: TripPlanningResponseDto, travelerCount: Int) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: Metric.pageSize)
        return renderer.pdfData { rendererContext in
            context = rendererContext
            pageNumber = 0
            drawCoverPage(response: response, travelerCount: travelerCount)
            drawOverviewPage(response: response)
            response.stops.forEach(drawStopPages)
            if !response.warnings.isEmpty {
                drawWarningsPage(warnings: response.warnings)
            }
        }
    }

    // MARK: - Cover

    private func drawCoverPage(response: TripPlanningResponseDto, travelerCount: Int) {
        pageNumber = 1
        context.beginPage()

        let headerRect = CGRect(x: 0, y: 0, width: Metric.pageSize.width, height: 300)
        drawGradient(in: headerRect, colors: [Palette.primary, Palette.primaryDark])

        draw(text: "W R A I T H", font: .systemFont(ofSize: 13, weight: .bold), color: .white.withAlphaComponent(0.85), rect: CGRect(x: Metric.margin, y: 40, width: contentWidth, height: 18))
        draw(text: "DETAYLI GEZİ PLANI", font: .systemFont(ofSize: 11, weight: .semibold), color: Palette.secondary, rect: CGRect(x: Metric.margin, y: 60, width: contentWidth, height: 16))

        let titleHeight = max(height(for: response.tripTitle, font: .systemFont(ofSize: 30, weight: .bold), width: contentWidth), 40)
        draw(text: response.tripTitle, font: .systemFont(ofSize: 30, weight: .bold), color: .white, rect: CGRect(x: Metric.margin, y: 92, width: contentWidth, height: titleHeight))

        var pillX = Metric.margin
        let pillY = 92 + titleHeight + 16
        let matchPill = drawPill("★ %\(Int(response.matchScore)) Eşleşme", font: .systemFont(ofSize: 12, weight: .bold), textColor: Palette.onSurface, backgroundColor: Palette.secondary, origin: CGPoint(x: pillX, y: pillY))
        pillX += matchPill.width + 8
        let travelerPill = drawPill("\(travelerCount) Kişi", font: .systemFont(ofSize: 12, weight: .semibold), textColor: .white, backgroundColor: .white.withAlphaComponent(0.2), origin: CGPoint(x: pillX, y: pillY))
        pillX += travelerPill.width + 8
        if let firstStop = response.stops.first, let lastStop = response.stops.last {
            drawPill("\(firstStop.arrivalDate) – \(lastStop.departureDate)", font: .systemFont(ofSize: 12, weight: .semibold), textColor: .white, backgroundColor: .white.withAlphaComponent(0.2), origin: CGPoint(x: pillX, y: pillY))
        }

        cursorY = 330
        drawSectionTitle("Genel Bakış")
        drawCard(text: response.tripSummary, font: .systemFont(ofSize: 13, weight: .regular), color: Palette.onSurface)

        if !response.personalizedInsights.isEmpty {
            cursorY += 6
            drawSubsectionTitle("Kişiselleştirilmiş İçgörüler")
            response.personalizedInsights.forEach(drawCheckRow)
        }
    }

    // MARK: - Overview

    private func drawOverviewPage(response: TripPlanningResponseDto) {
        startNewPage()
        drawSectionTitle("Tahmini Bütçe")

        let total = response.totalEstimatedCost
        let totalCardHeight: CGFloat = 62
        ensureSpace(totalCardHeight)
        let totalRect = CGRect(x: Metric.margin, y: cursorY, width: contentWidth, height: totalCardHeight)
        drawGradient(in: totalRect, colors: [Palette.primary, Palette.primaryDark], cornerRadius: 14)
        draw(text: "TOPLAM TAHMİNİ MALİYET", font: .systemFont(ofSize: 11, weight: .bold), color: .white.withAlphaComponent(0.85), rect: CGRect(x: totalRect.minX + 16, y: totalRect.minY + 10, width: totalRect.width - 32, height: 14))
        draw(text: "\(formattedAmount(total.amount)) \(total.currency)", font: .systemFont(ofSize: 22, weight: .bold), color: .white, rect: CGRect(x: totalRect.minX + 16, y: totalRect.minY + 28, width: totalRect.width - 32, height: 28))
        cursorY += totalCardHeight + 22

        let breakdown = response.budgetBreakdown
        let rows: [(String, String, Double)] = [
            ("house.fill", "Konaklama", breakdown.accommodation),
            ("fork.knife", "Yeme-İçme", breakdown.food),
            ("figure.hiking", "Aktiviteler", breakdown.activities),
            ("car.fill", "Ulaşım", breakdown.transport),
            ("shield.lefthalf.filled", "Yedek Bütçe", breakdown.buffer)
        ]
        let maxAmount = max(rows.map(\.2).max() ?? 1, 1)
        rows.forEach { drawBudgetRow(icon: $0.0, label: $0.1, amount: $0.2, currency: breakdown.currency, maxAmount: maxAmount) }
    }

    private func drawBudgetRow(icon: String, label: String, amount: Double, currency: String, maxAmount: Double) {
        let rowHeight: CGFloat = 42
        ensureSpace(rowHeight)

        drawCircleBadge(systemName: icon, diameter: 26, backgroundColor: Palette.surfaceVariant, tint: Palette.primary, center: CGPoint(x: Metric.margin + 13, y: cursorY + 13))
        draw(text: label, font: .systemFont(ofSize: 12.5, weight: .semibold), color: Palette.onSurface, rect: CGRect(x: Metric.margin + 34, y: cursorY, width: 160, height: 16))
        drawRightAligned(text: "\(formattedAmount(amount)) \(currency)", font: .systemFont(ofSize: 12.5, weight: .bold), color: Palette.primary, rightEdge: Metric.margin + contentWidth, y: cursorY)

        let barY = cursorY + 20
        let barTrackRect = CGRect(x: Metric.margin + 34, y: barY, width: contentWidth - 34, height: 6)
        Palette.outlineVariant.setFill()
        UIBezierPath(roundedRect: barTrackRect, cornerRadius: 3).fill()
        let fillWidth = max(barTrackRect.width * CGFloat(amount / maxAmount), 4)
        Palette.primary.setFill()
        UIBezierPath(roundedRect: CGRect(x: barTrackRect.minX, y: barTrackRect.minY, width: fillWidth, height: 6), cornerRadius: 3).fill()

        cursorY += rowHeight
    }

    // MARK: - Stops

    private func drawStopPages(_ stop: TripPlanningResponseStopDto) {
        startNewPage()

        let headerHeight: CGFloat = 64
        let headerRect = CGRect(x: Metric.margin, y: cursorY, width: contentWidth, height: headerHeight)
        Palette.primary.setFill()
        UIBezierPath(roundedRect: headerRect, cornerRadius: 14).fill()
        drawCircleBadge(systemName: "mappin.and.ellipse", diameter: 34, backgroundColor: .white.withAlphaComponent(0.2), tint: .white, center: CGPoint(x: headerRect.minX + 30, y: headerRect.midY))
        draw(text: "\(stop.stopNumber). DURAK", font: .systemFont(ofSize: 10, weight: .bold), color: .white.withAlphaComponent(0.8), rect: CGRect(x: headerRect.minX + 56, y: headerRect.minY + 12, width: headerRect.width - 70, height: 14))
        draw(text: "\(stop.cityName), \(stop.countryName)", font: .systemFont(ofSize: 17, weight: .bold), color: .white, rect: CGRect(x: headerRect.minX + 56, y: headerRect.minY + 28, width: headerRect.width - 70, height: 24))
        cursorY += headerHeight + 14

        var pillX = Metric.margin
        let datesPill = drawPill("\(stop.arrivalDate) – \(stop.departureDate)", font: .systemFont(ofSize: 11, weight: .semibold), textColor: Palette.onSurface, backgroundColor: Palette.surfaceVariant, origin: CGPoint(x: pillX, y: cursorY))
        pillX += datesPill.width + 8
        if let weather = stop.weatherForecastHint, !weather.isEmpty {
            drawPill(weather, font: .systemFont(ofSize: 11, weight: .semibold), textColor: Palette.onSurface, backgroundColor: Palette.surfaceVariant, origin: CGPoint(x: pillX, y: cursorY))
        }
        cursorY += datesPill.height + 18

        if !stop.localTips.isEmpty {
            drawSubsectionTitle("Yerel İpuçları")
            stop.localTips.forEach(drawCheckRow)
            cursorY += 4
        }
        if !stop.packingList.isEmpty {
            drawSubsectionTitle("Bavul Listesi")
            stop.packingList.forEach(drawCheckRow)
            cursorY += 4
        }

        stop.days.forEach(drawDay)
    }

    private func drawDay(_ day: TripPlanningDayDto) {
        cursorY += 12
        ensureSpace(70)

        let badgeSize = drawPill("GÜN \(day.dayNumber)", font: .systemFont(ofSize: 11, weight: .bold), textColor: .white, backgroundColor: Palette.primary, origin: CGPoint(x: Metric.margin, y: cursorY))
        let titleText = [day.theme, day.date].compactMap { $0 }.joined(separator: "  ·  ")
        draw(text: titleText, font: .systemFont(ofSize: 14, weight: .semibold), color: Palette.onSurface, rect: CGRect(x: Metric.margin + badgeSize.width + 10, y: cursorY + (badgeSize.height - 18) / 2, width: contentWidth - badgeSize.width - 10, height: 20))
        cursorY += badgeSize.height + 12

        Palette.outlineVariant.setFill()
        UIBezierPath(rect: CGRect(x: Metric.margin, y: cursorY, width: contentWidth, height: 1)).fill()
        cursorY += 10

        day.timeline.forEach(drawTimelineItem)
    }

    private func drawTimelineItem(_ item: TripPlanningTimelineItemDto) {
        let cardPadding: CGFloat = 10
        let indent: CGFloat = 34
        let textWidth = contentWidth - cardPadding * 2 - indent

        let headline = NSMutableAttributedString(
            string: "\(item.startTime)–\(item.endTime)  ",
            attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: Palette.primary]
        )
        headline.append(NSAttributedString(
            string: item.title,
            attributes: [.font: UIFont.systemFont(ofSize: 13.5, weight: .semibold), .foregroundColor: Palette.onSurface]
        ))
        let headlineHeight = ceil(headline.boundingRect(with: CGSize(width: textWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height)

        let descriptionHeight = item.description.isEmpty ? 0 : height(for: item.description, font: .systemFont(ofSize: 11.5, weight: .regular), width: textWidth) + 4
        let hasLocation = item.location?.isEmpty == false
        let locationHeight: CGFloat = hasLocation ? 16 : 0
        let hasCost = item.estimatedCost > 0
        let costHeight: CGFloat = hasCost ? 16 : 0

        let innerHeight = headlineHeight + descriptionHeight + locationHeight + costHeight
        let cardHeight = max(innerHeight, 26) + cardPadding * 2

        ensureSpace(cardHeight + 10)

        let cardRect = CGRect(x: Metric.margin, y: cursorY, width: contentWidth, height: cardHeight)
        Palette.surfaceVariant.setFill()
        UIBezierPath(roundedRect: cardRect, cornerRadius: 10).fill()
        let border = UIBezierPath(roundedRect: cardRect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 10)
        border.lineWidth = 1
        Palette.outlineVariant.setStroke()
        border.stroke()

        drawCircleBadge(systemName: categoryIcon(item.category), diameter: 22, backgroundColor: Palette.primary, tint: .white, center: CGPoint(x: cardRect.minX + cardPadding + 11, y: cardRect.minY + cardPadding + 11))

        let textX = cardRect.minX + cardPadding + indent
        var textY = cardRect.minY + cardPadding
        headline.draw(with: CGRect(x: textX, y: textY, width: textWidth, height: headlineHeight), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        textY += headlineHeight + 3

        if !item.description.isEmpty {
            draw(text: item.description, font: .systemFont(ofSize: 11.5, weight: .regular), color: Palette.onSurfaceVariant, rect: CGRect(x: textX, y: textY, width: textWidth, height: descriptionHeight))
            textY += descriptionHeight
        }
        if hasLocation, let location = item.location {
            drawIcon(systemName: "mappin.and.ellipse", tint: Palette.primary, in: CGRect(x: textX, y: textY + 2, width: 11, height: 11), pointSize: 10)
            draw(text: location, font: .systemFont(ofSize: 11, weight: .medium), color: Palette.primary, rect: CGRect(x: textX + 15, y: textY, width: textWidth - 15, height: locationHeight))
            textY += locationHeight
        }
        if hasCost {
            draw(text: "~ \(formattedAmount(item.estimatedCost)) TL", font: .systemFont(ofSize: 11, weight: .semibold), color: Palette.onSurface, rect: CGRect(x: textX, y: textY, width: textWidth, height: costHeight))
        }

        cursorY += cardHeight + 10
    }

    private func categoryIcon(_ category: String) -> String {
        switch category.uppercased() {
        case "SIGHTSEEING": return "camera.fill"
        case "FOOD", "DINING", "RESTAURANT": return "fork.knife"
        case "SHOPPING": return "bag.fill"
        case "RELAXATION", "REST", "WELLNESS": return "leaf.fill"
        case "TRANSPORT", "TRANSPORTATION": return "car.fill"
        case "NIGHTLIFE": return "moon.stars.fill"
        case "CULTURE", "MUSEUM": return "building.columns.fill"
        case "ADVENTURE", "ACTIVITY": return "figure.hiking"
        case "BEACH": return "beach.umbrella.fill"
        default: return "mappin.and.ellipse"
        }
    }

    // MARK: - Warnings

    private func drawWarningsPage(warnings: [TripPlanningWarningDto]) {
        startNewPage()
        drawSectionTitle("Uyarılar")
        warnings.forEach(drawWarningCard)
    }

    private func drawWarningCard(_ warning: TripPlanningWarningDto) {
        let padding: CGFloat = 12
        let indent: CGFloat = 30
        let textWidth = contentWidth - padding * 2 - indent
        let typeHeight: CGFloat = 14
        let messageHeight = height(for: warning.message, font: .systemFont(ofSize: 12, weight: .regular), width: textWidth)
        let cardHeight = typeHeight + messageHeight + padding * 2 + 4

        ensureSpace(cardHeight + 10)

        let rect = CGRect(x: Metric.margin, y: cursorY, width: contentWidth, height: cardHeight)
        Palette.secondary.withAlphaComponent(0.28).setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 10).fill()
        drawIcon(systemName: "exclamationmark.triangle.fill", tint: Palette.primary, in: CGRect(x: rect.minX + padding, y: rect.minY + padding, width: 18, height: 18), pointSize: 16)

        draw(text: warning.type, font: .systemFont(ofSize: 11, weight: .bold), color: Palette.primary, rect: CGRect(x: rect.minX + padding + indent, y: rect.minY + padding, width: textWidth, height: typeHeight))
        draw(text: warning.message, font: .systemFont(ofSize: 12, weight: .regular), color: Palette.onSurface, rect: CGRect(x: rect.minX + padding + indent, y: rect.minY + padding + typeHeight + 4, width: textWidth, height: messageHeight))

        cursorY += cardHeight + 10
    }

    // MARK: - Page helpers

    private var contentWidth: CGFloat { Metric.pageSize.width - Metric.margin * 2 }
    private var contentBottom: CGFloat { Metric.pageSize.height - Metric.margin }

    private func startNewPage() {
        context.beginPage()
        pageNumber += 1
        cursorY = Metric.margin
        drawFooter()
    }

    private func ensureSpace(_ requiredHeight: CGFloat) {
        if cursorY + requiredHeight > contentBottom {
            startNewPage()
        }
    }

    private func drawFooter() {
        let y = Metric.pageSize.height - 26
        Palette.outlineVariant.setFill()
        UIBezierPath(rect: CGRect(x: Metric.margin, y: y, width: contentWidth, height: 0.6)).fill()
        drawRightAligned(text: "Wraith  ·  Sayfa \(pageNumber)", font: .systemFont(ofSize: 9, weight: .regular), color: Palette.onSurfaceVariant, rightEdge: Metric.margin + contentWidth, y: y + 6)
    }

    // MARK: - Text block helpers

    private func drawSectionTitle(_ text: String) {
        ensureSpace(30)
        draw(text: text, font: .systemFont(ofSize: 20, weight: .bold), color: Palette.primary, rect: CGRect(x: Metric.margin, y: cursorY, width: contentWidth, height: 26))
        cursorY += 34
    }

    private func drawSubsectionTitle(_ text: String) {
        ensureSpace(24)
        draw(text: text, font: .systemFont(ofSize: 15, weight: .bold), color: Palette.onSurface, rect: CGRect(x: Metric.margin, y: cursorY, width: contentWidth, height: 20))
        cursorY += 26
    }

    private func drawCard(text: String, font: UIFont, color: UIColor) {
        let padding: CGFloat = 14
        let textWidth = contentWidth - padding * 2
        let textHeight = height(for: text, font: font, width: textWidth)
        let cardHeight = textHeight + padding * 2
        ensureSpace(cardHeight)
        let rect = CGRect(x: Metric.margin, y: cursorY, width: contentWidth, height: cardHeight)
        Palette.surfaceVariant.setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 12).fill()
        draw(text: text, font: font, color: color, rect: CGRect(x: rect.minX + padding, y: rect.minY + padding, width: textWidth, height: textHeight))
        cursorY += cardHeight + 10
    }

    private func drawCheckRow(_ text: String) {
        let indent: CGFloat = 20
        let textWidth = contentWidth - indent
        let textHeight = height(for: text, font: .systemFont(ofSize: 12, weight: .regular), width: textWidth)
        ensureSpace(textHeight + 6)
        drawIcon(systemName: "checkmark.seal.fill", tint: Palette.primary, in: CGRect(x: Metric.margin, y: cursorY + 1, width: 14, height: 14), pointSize: 13)
        draw(text: text, font: .systemFont(ofSize: 12, weight: .regular), color: Palette.onSurface, rect: CGRect(x: Metric.margin + indent, y: cursorY, width: textWidth, height: textHeight))
        cursorY += textHeight + 8
    }

    // MARK: - Primitive drawing helpers

    private func drawGradient(in rect: CGRect, colors: [UIColor], cornerRadius: CGFloat = 0) {
        guard let cgContext = UIGraphicsGetCurrentContext() else { return }
        cgContext.saveGState()
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        let cgColors = colors.map(\.cgColor) as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors, locations: nil) {
            cgContext.drawLinearGradient(gradient, start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
        }
        cgContext.restoreGState()
    }

    private func drawIcon(systemName: String, tint: UIColor, in rect: CGRect, pointSize: CGFloat) {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
        guard let image = UIImage(systemName: systemName, withConfiguration: configuration)?.withTintColor(tint, renderingMode: .alwaysOriginal) else { return }
        let aspect = image.size.width / max(image.size.height, 1)
        let drawSize = rect.width / rect.height > aspect
            ? CGSize(width: rect.height * aspect, height: rect.height)
            : CGSize(width: rect.width, height: rect.width / aspect)
        let origin = CGPoint(x: rect.midX - drawSize.width / 2, y: rect.midY - drawSize.height / 2)
        image.draw(in: CGRect(origin: origin, size: drawSize))
    }

    private func drawCircleBadge(systemName: String, diameter: CGFloat, backgroundColor: UIColor, tint: UIColor, center: CGPoint) {
        let rect = CGRect(x: center.x - diameter / 2, y: center.y - diameter / 2, width: diameter, height: diameter)
        backgroundColor.setFill()
        UIBezierPath(ovalIn: rect).fill()
        let inset = diameter * 0.28
        drawIcon(systemName: systemName, tint: tint, in: rect.insetBy(dx: inset, dy: inset), pointSize: diameter - inset * 2)
    }

    @discardableResult
    private func drawPill(_ text: String, font: UIFont, textColor: UIColor, backgroundColor: UIColor, origin: CGPoint) -> CGSize {
        let textSize = (text as NSString).size(withAttributes: [.font: font])
        let horizontalPadding: CGFloat = 12
        let verticalPadding: CGFloat = 6
        let pillSize = CGSize(width: textSize.width + horizontalPadding * 2, height: textSize.height + verticalPadding * 2)
        let rect = CGRect(origin: origin, size: pillSize)
        backgroundColor.setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: pillSize.height / 2).fill()
        draw(text: text, font: font, color: textColor, rect: CGRect(x: rect.minX + horizontalPadding, y: rect.minY + verticalPadding, width: textSize.width, height: textSize.height))
        return pillSize
    }

    private func draw(text: String, font: UIFont, color: UIColor, rect: CGRect) {
        (text as NSString).draw(in: rect, withAttributes: [.font: font, .foregroundColor: color])
    }

    private func drawRightAligned(text: String, font: UIFont, color: UIColor, rightEdge: CGFloat, y: CGFloat) {
        let size = (text as NSString).size(withAttributes: [.font: font])
        draw(text: text, font: font, color: color, rect: CGRect(x: rightEdge - size.width, y: y, width: size.width, height: size.height))
    }

    private func height(for text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(bounds.height)
    }

    private func formattedAmount(_ amount: Double) -> String {
        Self.numberFormatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        return formatter
    }()
}
