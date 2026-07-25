//
//  TripDetailViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Placeholder destination for a selected trip card — content to be designed later.
final class TripDetailViewController: UIViewController {

    // MARK: - Properties

    private let trip: PopularTrip

    // MARK: - Init

    init(trip: PopularTrip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = trip.title
    }
}
