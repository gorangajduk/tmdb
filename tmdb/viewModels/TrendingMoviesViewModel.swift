//
//  TrendingMoviesViewModel.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation
import Combine

/// A view model responsible for fetching and managing trending movie data.
/// It observes changes in movie data and pagination state, making them available to the UI.
///
/// Marked with `@MainActor` to ensure all state updates and UI-related logic
/// are executed on the main thread, preventing potential race conditions
/// and ensuring thread safety for UI-bound properties.
@MainActor
final class TrendingMoviesViewModel: ObservableObject {

    /// Published property holding the list of trending movies.
    /// UI elements observing this property will automatically update when `movies` changes.
    @Published var movies: [Movie] = []

    /// Published property indicating if a new page of movies is currently being loaded.
    @Published var isLoadingPage = false

    /// Published property to communicate any errors that occur during data fetching.
    @Published var errorMessage: String?

    /// Tracks the current page number for pagination requests.
    private var currentPage = 1

    /// Stores the total number of pages available from the API, used to stop pagination.
    private var totalPages = 1

    /// A set to hold Combine cancellables, managing the lifecycle of subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Initializes the view model and immediately kicks off the first data fetch.
    init() {
        fetchTrendingMovies()
    }

    /// Fetches a new page of trending movies from The MovieDB API.
    /// This method includes logic to prevent redundant requests and handles pagination limits.
    func fetchTrendingMovies() {
        // Prevent fetching if already loading or if all pages have been loaded.
        guard !isLoadingPage && currentPage <= totalPages else { return }

        isLoadingPage = true
        errorMessage = nil // Clear any previous error message

        // Use a Task for asynchronous network operations.
        // Since the ViewModel is @MainActor, updates to @Published properties
        // within this Task's `do` and `catch` blocks are automatically
        // dispatched to the main actor, removing the need for explicit `DispatchQueue.main.async`.
        Task {
            do {
                let response: TrendingMoviesResponse = try await NetworkService.shared.request(
                    endpoint: Constants.Endpoint.trendingMovies(page: currentPage)
                )

                // Append new movies and update pagination state.
                self.movies.append(contentsOf: response.results)
                self.currentPage += 1
                self.totalPages = response.totalPages
                self.isLoadingPage = false
            } catch {
                // Handle network or decoding errors.
                self.errorMessage = error.localizedDescription
                self.isLoadingPage = false
            }
        }
    }

    /// Checks if more content needs to be loaded for infinite scrolling.
    /// This method is typically called when a user scrolls near the end of the current list.
    /// - Parameter currentMovie: The movie currently being displayed, used to determine
    ///   if the user is near the end of the loaded content.
    func loadMoreContentIfNeeded(currentMovie: Movie?) {
        guard let currentMovie = currentMovie else { return }

        // Determine if the currently displayed movie is within the last 5 items
        // of the loaded `movies` array. This acts as a trigger for pagination.
        let thresholdIndex = movies.index(movies.endIndex, offsetBy: -5, limitedBy: 0) ?? 0

        if movies.firstIndex(where: { $0.id == currentMovie.id }) == thresholdIndex {
            fetchTrendingMovies()
        }
    }
}
