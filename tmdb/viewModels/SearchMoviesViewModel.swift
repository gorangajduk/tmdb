//
//  SearchMoviesViewModel.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation
import Combine 
import tmdbKit

/// A view model responsible for handling movie search queries and managing search results.
/// It includes debouncing to optimize API calls and pagination for search results.
///
/// Marked with `@MainActor` to ensure all UI-related state updates happen on the main thread.
@MainActor
final class SearchMoviesViewModel: ObservableObject {

    /// Published property holding the current search query entered by the user.
    /// Changes to this property will trigger a debounced search.
    @Published var searchQuery: String = "" {
        didSet {
            // Trigger a new search whenever the search query changes,
            // but only after a short delay (debouncing).
            debouncedSearchSubject.send(searchQuery)
        }
    }

    /// Published property holding the list of movies found based on the search query.
    @Published var searchResults: [Movie] = []

    /// Published property indicating if a search operation is currently in progress.
    @Published var isLoading = false

    /// Published property to communicate any errors encountered during the search.
    @Published var errorMessage: String?

    /// Tracks the current page number for paginating search results.
    private var currentPage = 1

    /// Stores the total number of pages available for the current search query,
    /// used to determine when to stop fetching more results.
    private var totalPages = 1

    /// A PassthroughSubject to debounce search queries.
    /// This prevents an API call on every keystroke, reducing unnecessary network traffic.
    private let debouncedSearchSubject = PassthroughSubject<String, Never>()

    /// A set to store Combine cancellables, managing the lifecycle of subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Initializes the view model and sets up the debouncing logic for search queries.
    init() {
        // Debounce the search query:
        // - `debounce` waits for a specified time interval (0.5 seconds)
        //   before emitting a new value, only if no new values arrive.
        // - `removeDuplicates()` prevents triggering search for identical consecutive queries.
        // - `compactMap` ensures we only proceed with non-empty queries.
        debouncedSearchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // Clean whitespace
            .sink { [weak self] query in
                // Only perform search if the query is not empty after debouncing
                if !query.isEmpty {
                    self?.resetAndPerformSearch(query: query)
                } else {
                    // Clear results if query becomes empty
                    self?.searchResults = []
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }

    /// Resets pagination state and performs a new search for a given query.
    /// This is called when a *new* search term is actively entered.
    /// - Parameter query: The search term to use for the API call.
    private func resetAndPerformSearch(query: String) {
        self.currentPage = 1
        self.totalPages = 1 // Reset total pages to 1 until first response
        self.searchResults = [] // Clear previous results
        self.performSearch(query: query)
    }

    /// Executes the movie search API call for the current `searchQuery` and `currentPage`.
    /// Handles loading states, API requests, and error management.
    /// - Parameter query: The search term to use. If nil, `self.searchQuery` is used.
    func performSearch(query: String? = nil) {
        let currentQuery = query ?? searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        // Do not proceed if query is empty or already loading a page,
        // or if all pages for the current query have been loaded.
        guard !currentQuery.isEmpty, !isLoading, currentPage <= totalPages else { return }

        isLoading = true
        errorMessage = nil // Clear any previous error

        Task {
            do {
                let response: TrendingMoviesResponse = try await NetworkService.shared.searchMovies(query: currentQuery,
                                                                                                    page: currentPage)

                // Update published properties on the main actor.
                self.searchResults.append(contentsOf: response.results)
                self.currentPage += 1
                self.totalPages = response.totalPages
                self.isLoading = false
            } catch {
                // Handle any network or decoding errors.
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Checks if more content needs to be loaded for infinite scrolling of search results.
    /// This method is typically called when a user scrolls near the end of the current list.
    /// - Parameter currentMovie: The movie currently being displayed, used to determine
    ///   if the user is near the end of the loaded content.
    func loadMoreContentIfNeeded(currentMovie: Movie?) {
        guard let currentMovie = currentMovie, !searchQuery.isEmpty else { return }

        // Determine if the currently displayed movie is within the last 5 items
        // of the loaded `searchResults` array.
        let thresholdIndex = searchResults.index(searchResults.endIndex, offsetBy: -5, limitedBy: 0) ?? 0

        if searchResults.firstIndex(where: { $0.id == currentMovie.id }) == thresholdIndex {
            performSearch() // Fetch the next page of results
        }
    }
}
