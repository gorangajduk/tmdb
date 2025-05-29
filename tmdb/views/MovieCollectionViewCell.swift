//
//  MovieCell.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import UIKit
import SwiftUI // Essential for embedding SwiftUI views within UIKit

/// A custom `UICollectionViewCell` designed to host a SwiftUI `View` (`MovieCardView`).
/// This bridge allows `UICollectionView` to display rich, declarative SwiftUI content.
class MovieCollectionViewCell: UICollectionViewCell {
    /// A unique identifier for dequeuing cells from the collection view.
    static let reuseIdentifier = "MovieCollectionViewCell"

    /// The `UIHostingController` instance that manages the SwiftUI `MovieCardView`.
    /// It's declared as `var` and `internal` so the parent `UIViewController` can
    /// manage its lifecycle (adding/removing as child view controller).
    var hostingController: UIHostingController<AnyView>?

    // MARK: - Initialization

    /// Initializes the cell with a given frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHostingController()
    }

    /// Initializes the cell from a storyboard or NIB.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingController()
    }

    /// Sets up the `UIHostingController` and embeds its view into the cell's `contentView`.
    /// This method is called once during the cell's initialization.
    private func setupHostingController() {
        // Initialize the host with an empty SwiftUI view to start.
        // The actual movie content will be set later in `configure(with:)`.
        hostingController = UIHostingController(rootView: AnyView(EmptyView()))
        
        // Ensure the host's view is available.
        guard let hostView = hostingController?.view else { return }

        // Disable autoresizing masks to use Auto Layout constraints.
        hostView.translatesAutoresizingMaskIntoConstraints = false
        // Add the SwiftUI view as a subview to the collection view cell's content view.
        contentView.addSubview(hostView)

        // Activate Auto Layout constraints to make the SwiftUI view fill the entire cell.
        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    // MARK: - Cell Lifecycle

    /// Prepares the cell for reuse by the collection view.
    /// This method is called just before the cell is returned from the reuse queue.
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the SwiftUI view's content to an empty state.
        // This prevents flickering or display of old data when the cell is reused.
        hostingController?.rootView = AnyView(EmptyView())
    }

    /// Configures the cell with new movie data by updating the SwiftUI content.
    /// - Parameter movie: The `Movie` object to display in the cell.
    func configure(with movie: Movie) {
        // Update the root view of the existing `UIHostingController` with the new movie data.
        // This efficiently updates the SwiftUI content without recreating the hosting controller.
        hostingController?.rootView = AnyView(MovieCardView(movie: movie))
    }
}
