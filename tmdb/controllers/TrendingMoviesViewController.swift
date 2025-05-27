//
//  TrendingMoviesViewController.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import UIKit
import Combine
import SwiftUI // Required for UIHostingController to embed SwiftUI views

/// A UIViewController subclass responsible for displaying a collection of trending movies.
/// It uses a UICollectionView for the list presentation and integrates SwiftUI views
/// within its cells for a modern UI approach.
class TrendingMoviesViewController: UIViewController {

    /// IBOutllet for the UICollectionView, connected from the Storyboard.
    @IBOutlet weak var collectionView: UICollectionView!

    /// The ViewModel that handles data fetching and business logic for trending movies.
    /// It provides observable properties for UI updates.
    private var viewModel = TrendingMoviesViewModel()

    /// A set to store Combine cancellables, ensuring subscriptions are properly
    /// managed and released to prevent memory leaks.
    private var cancellables = Set<AnyCancellable>()

    /// A dictionary to keep track of active UIHostingControllers for each displayed cell.
    /// This is crucial for correctly managing the lifecycle of embedded SwiftUI views
    /// when cells are reused.
    private var activeHostingControllers: [IndexPath: UIHostingController<AnyView>] = [:]

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trending Movies"
        setupCollectionView()
        bindViewModel()
    }

    // MARK: - Setup Methods

    /// Configures the UICollectionView's data source, delegate, cell registration, and layout.
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        // Register the custom UICollectionViewCell which acts as a container for SwiftUI views.
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)

        // Configure the flow layout for the collection view.
        // This provides basic grid-like arrangement with predefined item sizes and section insets.
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (collectionView.bounds.width / 2) - 15, height: 250) // Example size, adjusted in delegate for responsiveness
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }

    /// Establishes Combine subscriptions to the ViewModel's published properties.
    /// This allows the UI to react to changes in the movie data and error states.
    private func bindViewModel() {
        // Subscribe to changes in the `movies` array from the ViewModel.
        // When new movies are loaded, the collection view reloads its data.
        viewModel.$movies
            .receive(on: DispatchQueue.main) // Ensure UI updates occur on the main thread
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        // Subscribe to error messages from the ViewModel.
        // If an error occurs, an alert is presented to the user.
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main) // Ensure UI updates occur on the main thread
            .sink { [weak self] message in
                if let message = message {
                    self?.presentErrorAlert(message: message)
                }
            }
            .store(in: &cancellables)
    }

    /// Presents a UIAlertController to display an error message to the user.
    /// - Parameter message: The localized description of the error to be displayed.
    private func presentErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UIHostingController Lifecycle Management in Cells

    /// Handles view transitions (e.g., device rotation) to invalidate the collection view's layout.
    /// This ensures the layout adapts correctly to the new size and orientation.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            // Invalidate the layout to trigger `collectionView(_:layout:sizeForItemAt:)`
            // recalculation, allowing for adaptive item sizing.
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    /// Delegate method called just before a cell is displayed.
    /// This is where the UIHostingController for the cell's SwiftUI content is
    /// added as a child view controller to ensure proper lifecycle management.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let movieCell = cell as? MovieCollectionViewCell, let host = movieCell.hostingController {
            // Add the hosting controller as a child view controller of this UIViewController.
            // This is essential for SwiftUI view's lifecycle methods (e.g., .onAppear) to work.
            addChild(host)
            // Notify the host that it has been moved to a parent view controller.
            host.didMove(toParent: self)
            // Keep a reference to the active host for later removal.
            activeHostingControllers[indexPath] = host
        }

        // Trigger loading of more content if the user scrolls near the end of the list.
        let movie = viewModel.movies[indexPath.item]
        viewModel.loadMoreContentIfNeeded(currentMovie: movie)
    }

    /// Delegate method called after a cell is no longer visible.
    /// This is where the UIHostingController for the cell's SwiftUI content is
    /// removed from the child view controller hierarchy to clean up resources.
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let movieCell = cell as? MovieCollectionViewCell, let host = movieCell.hostingController {
            // Notify the host that it will be removed from its parent view controller.
            host.willMove(toParent: nil)
            // Remove the host from the child view controller hierarchy.
            host.removeFromParent()
            // Clear the reference from active hosts.
            activeHostingControllers[indexPath] = nil
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrendingMoviesViewController: UICollectionViewDataSource {
    /// Returns the number of items to display in the collection view.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    /// Provides a configured cell for each item in the collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Failed to dequeue MovieCollectionViewCell. Ensure it's registered correctly.")
        }
        let movie = viewModel.movies[indexPath.item]
        cell.configure(with: movie) // Configure the cell with movie data
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TrendingMoviesViewController: UICollectionViewDelegate {
    /// Handles item selection in the collection view by navigating to the Movie Detail Screen.
    /// - Parameter indexPath: The index path of the selected movie.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = viewModel.movies[indexPath.item]
        
        // 1. Create an instance of the SwiftUI MovieDetailView with the selected movie's ID.
        let detailSwiftUIView = MovieDetailView(movieId: selectedMovie.id)
        
        // 2. Wrap the SwiftUI view in a UIHostingController.
        let detailViewController = UIHostingController(rootView: detailSwiftUIView)
        
        // 3. Set a title for the navigation bar on the detail screen.
        detailViewController.title = selectedMovie.title
        
        // 4. Push the UIHostingController onto the navigation stack.
        // Ensure that TrendingMoviesViewController is embedded in a UINavigationController
        // in your Storyboard or programmatically.
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrendingMoviesViewController: UICollectionViewDelegateFlowLayout {
    /// Determines the size for each item in the collection view, adapting to device orientation and type.
    /// - Parameters:
    ///   - collectionView: The collection view requesting the layout information.
    ///   - collectionViewLayout: The layout object for the collection view.
    ///   - indexPath: The index path of the item.
    /// - Returns: The size for the item at the specified index path.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10 // Horizontal padding on each side of the collection view
        let minimumInteritemSpacing: CGFloat = 10 // Minimum space between items
        // Determine number of items per row based on device type.
        // iPad shows 3 items, iPhone shows 2 for better responsiveness.
        let itemsPerRow: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2

        // Calculate available width for items, considering padding and spacing.
        let availableWidth = collectionView.bounds.width - (padding * 2) - (minimumInteritemSpacing * (itemsPerRow - 1))
        let width = availableWidth / itemsPerRow
        let height: CGFloat = 250 // Fixed height for consistency

        return CGSize(width: width, height: height)
    }
}
