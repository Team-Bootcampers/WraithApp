//
//  TicketListViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class TicketListViewController: UIViewController {

    // MARK: - UI Components

    private lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    // MARK: - Properties

    private let city: String?
    private let startDate: Date?
    private let endDate: Date?

    // MARK: - Init

    init(city: String?, startDate: Date?, endDate: Date?) {
        self.city = city
        self.startDate = startDate
        self.endDate = endDate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Biletler"
        view.backgroundColor = .systemGroupedBackground
        setupLayout()
        summaryLabel.text = summaryText()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(summaryLabel)
        NSLayoutConstraint.activate([
            summaryLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Helpers

    private func summaryText() -> String {
        let cityText = city ?? "Seçilmedi"

        let dateText: String
        if let startDate {
            if let endDate {
                dateText = "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
            } else {
                dateText = dateFormatter.string(from: startDate)
            }
        } else {
            dateText = "Seçilmedi"
        }

        return "Şehir: \(cityText)\nTarih: \(dateText)"
    }
}
