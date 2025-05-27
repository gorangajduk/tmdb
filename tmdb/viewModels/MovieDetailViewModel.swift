//
//  MovieDetailViewModel.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation
import Combine // For @Published

/// A view model responsible for fetching and managing detailed information for a single movie.
/// It observes loading and error states and exposes them to the UI.
///
/// Marked with `@MainActor` to ensure all state updates are performed on the main thread,
/// which is crucial for SwiftUI view updates and overall thread safety.
@MainActor
final class MovieDetailViewModel: ObservableObject {

    /// The unique identifier of the movie for which details are being fetched.
    private let movieId: Int

    /// Published property holding the detailed `MovieDetail` object.
    /// SwiftUI views observing this will update when movie details are loaded.
    @Published var movieDetail: MovieDetail?

    /// Published property indicating if movie details are currently being loaded.
    @Published var isLoading = false

    /// Published property to communicate any errors that occur during data fetching.
    @Published var errorMessage: String?

    /// Initializes the view model with a specific movie ID and immediately
    /// triggers the fetch for movie details.
    /// - Parameter movieId: The ID of the movie to fetch details for.
    init(movieId: Int) {
        self.movieId = movieId
        fetchMovieDetail()
    }

    /// Fetches the detailed information for the movie from The MovieDB API.
    /// This method handles loading states, API requests, and error management.
    func fetchMovieDetail() {
        // Prevent fetching if already loading.
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil // Clear any previous error

        // Use a Task for asynchronous network operations.
        // As the ViewModel is @MainActor, all subsequent updates to @Published properties
        // within this Task's scope will automatically be dispatched to the main actor.
        Task {
            do {
                let endpoint = Constants.Endpoint.movieDetails(id: movieId)
                let detail: MovieDetail = try await NetworkService.shared.request(endpoint: endpoint)
                
                // Update published properties on the main actor.
                self.movieDetail = detail
                self.isLoading = false
            } catch {
                // Handle any network or decoding errors.
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
