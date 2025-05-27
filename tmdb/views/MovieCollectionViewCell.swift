//
//  MovieCell.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import UIKit
import SwiftUI // Crucial for UIHostingController

class MovieCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieCollectionViewCell"

    // Make the host public or internal so the parent VC can access it
    var hostingController: UIHostingController<AnyView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHostingController()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingController()
    }

    private func setupHostingController() {
        // Initialize the host once per cell
        hostingController = UIHostingController(rootView: AnyView(EmptyView())) // Start with EmptyView
        guard let hostView = hostingController?.view else { return }

        hostView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostView)

        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // No need to remove/recreate host, just update its view
        hostingController?.rootView = AnyView(EmptyView()) // Reset content for reuse
    }

    func configure(with movie: Movie) {
        // Update the root view of the existing hosting controller
        hostingController?.rootView = AnyView(MovieCardView(movie: movie))
    }
}
