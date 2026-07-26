//
//  PDFViewerViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit
import PDFKit

/// Displays a generated trip-plan PDF with a share/download action — reusable wherever a
/// saved trip's PDF needs to be opened from "Seyahatlerim".
final class PDFViewerViewController: UIViewController {

    // MARK: - UI Components

    private lazy var pdfView: PDFView = {
        let view = PDFView()
        view.autoScales = true
        view.backgroundColor = .wraithBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    private let fileURL: URL
    private var hasScrolledToFirstPage = false

    // MARK: - Init

    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gezi Planı"
        view.backgroundColor = .wraithBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(didTapShare))
        pdfView.document = PDFDocument(url: fileURL)
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // `autoScales` only settles once the view has its real, non-zero frame — jumping to
        // the first page before that (e.g. from `viewDidLoad`) landed mid-document instead
        // of at the top. Doing it once here, after layout, is the reliable point.
        guard !hasScrolledToFirstPage, pdfView.document != nil else { return }
        hasScrolledToFirstPage = true
        pdfView.goToFirstPage(nil)
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func didTapShare() {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityViewController, animated: true)
    }
}
