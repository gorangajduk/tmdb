//
//  TrendingMoviesViewController.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import UIKit
import Combine
import SwiftUI // For UIHostingController

class TrendingMoviesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel = TrendingMoviesViewModel()
    private var cancellables = Set<AnyCancellable>()

    // Keep track of active child hosting controllers for proper lifecycle management
    private var activeHostingControllers: [IndexPath: UIHostingController<AnyView>] = [:]


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trending Movies"
        setupCollectionView()
        bindViewModel()
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (collectionView.bounds.width / 2) - 15, height: 250)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }

    private func bindViewModel() {
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    self?.presentErrorAlert(message: message)
                }
            }
            .store(in: &cancellables)
    }
    
    private func presentErrorAlert(message: String) {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }

    // --- Lifecycle Management for UIHostingController in Cells ---
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    // This method is called when a cell is about to be displayed
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let movieCell = cell as? MovieCollectionViewCell, let host = movieCell.hostingController {
            // Add the hosting controller as a child *before* it's displayed
            addChild(host)
            host.didMove(toParent: self)
            activeHostingControllers[indexPath] = host
        }

        let movie = viewModel.movies[indexPath.item]
        viewModel.loadMoreContentIfNeeded(currentMovie: movie)
    }

    // This method is called when a cell is no longer visible
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let movieCell = cell as? MovieCollectionViewCell, let host = movieCell.hostingController {
            // Remove the hosting controller as a child when it's no longer displayed
            host.willMove(toParent: nil)
            host.removeFromParent()
            activeHostingControllers[indexPath] = nil
        }
    }
}

extension TrendingMoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Unable to dequeue MovieCollectionViewCell")
        }
        let movie = viewModel.movies[indexPath.item]
        cell.configure(with: movie)
        return cell
    }
}

extension TrendingMoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = viewModel.movies[indexPath.item]
        // TODO: Navigate to Movie Details Screen
        print("Selected: \(selectedMovie.title)")
    }
}

extension TrendingMoviesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let minimumInteritemSpacing: CGFloat = 10
        let itemsPerRow: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2

        let availableWidth = collectionView.bounds.width - (padding * 2) - (minimumInteritemSpacing * (itemsPerRow - 1))
        let width = availableWidth / itemsPerRow
        let height: CGFloat = 250

        return CGSize(width: width, height: height)
    }
}
