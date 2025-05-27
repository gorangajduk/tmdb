//
//  SearchMoviesView.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import SwiftUI

/// A SwiftUI view that provides a search interface for movies.
/// It integrates a search bar into the navigation bar and displays results
/// in a scrollable grid, managing state via `SearchMoviesViewModel`.
struct SearchMoviesView: View {
    /// The ViewModel that handles search logic, data fetching, and state management.
    /// @StateObject ensures the ViewModel's lifecycle is tied to this view's lifecycle.
    @StateObject var viewModel = SearchMoviesViewModel()

    /// Defines the adaptive grid layout for displaying movie cards.
    /// It creates columns that fit available space, with a minimum width of 150 points.
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), spacing: 10)
    ]

    var body: some View {
        // Embed in NavigationView to enable .searchable modifier and navigation title
        NavigationView {
            ScrollView {
                // MARK: - Search Results Grid
                // Displays the fetched movie results in a grid.
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.searchResults) { movie in
                        MovieCardView(movie: movie)
                            .onAppear {
                                // Trigger loading of more content when user scrolls near the end
                                viewModel.loadMoreContentIfNeeded(currentMovie: movie)
                            }
                    }
                }
                .padding(.horizontal) // Apply horizontal padding to the grid

                // MARK: - Loading Indicator
                // Shows a progress view at the bottom when more data is loading.
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                // MARK: - Error Message
                // Displays an error message if fetching fails.
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                }

                // MARK: - Empty State Message
                // Shows a prompt if no search results are found or if the search bar is empty.
                if viewModel.searchResults.isEmpty && !viewModel.isLoading && viewModel.searchQuery.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                        Text("Search for movies")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if viewModel.searchResults.isEmpty && !viewModel.isLoading && !viewModel.searchQuery.isEmpty && viewModel.errorMessage == nil {
                    VStack {
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                        Text("No results found for \"\(viewModel.searchQuery)\"")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                }
            }
            .navigationTitle("Search Movies") // Title for the navigation bar
            // MARK: - Search Bar Integration
            // Adds a searchable text field to the navigation bar.
            // The text entered binds directly to viewModel.searchQuery.
            .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .always))
            .autocorrectionDisabled() // Disable autocorrection for better search experience
        }
    }
}

// MARK: - Preview Provider

/// Provides a preview for `SearchMoviesView` in Xcode's canvas.
struct SearchMoviesView_Previews: PreviewProvider {
    static var previews: some View {
        SearchMoviesView()
    }
}
