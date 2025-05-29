//
//  Untitled.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import SwiftUI

/// A SwiftUI view responsible for displaying the detailed information of a single movie.
/// It observes a `MovieDetailViewModel` to fetch and present movie data.
struct MovieDetailView: View {
    /// An `ObservableObject` that manages the fetching and state of the movie details.
    /// The view will automatically re-render when `movieDetailViewModel`'s published properties change.
    @StateObject var movieDetailViewModel: MovieDetailViewModel
    
    @ObservedObject private var favoritesManager = FavoriteMoviesManager.shared

    /// Initializes the `MovieDetailView` with the ID of the movie to display.
    /// - Parameter movieId: The unique identifier of the movie for which details are to be fetched.
    init(movieId: Int) {
        _movieDetailViewModel = StateObject(wrappedValue: MovieDetailViewModel(movieId: movieId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Backdrop Image
                // Displays a large backdrop image at the top of the detail view.
                ProgressiveImageView(
                    lowResURL: movieDetailViewModel.movieDetail?.backdropThumbnailURL, // Your small backdrop image
                    highResURL: movieDetailViewModel.movieDetail?.backdropURL, // Your large backdrop image
                    contentMode: .fill,
                    lowResBlurRadius: 5.0, // More blur for backdrop
                    noImageIcon: "film.fill" // Use a system icon for backdrop placeholder if no image
                )
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped() // Crucial for fill contentMode
                .shadow(radius: 10)
                
                // MARK: - Movie Header (Poster, Title, Tagline)
                HStack(alignment: .top, spacing: 20) {
                    // Movie Poster
                    ProgressiveImageView(
                        lowResURL: movieDetailViewModel.movieDetail?.posterURL, // Your w200 poster
                        highResURL: movieDetailViewModel.movieDetail?.detailPosterURL, // Your w500 poster
                        contentMode: .fit,
                        lowResBlurRadius: 2.0,
                        noImageText: "No Poster"
                    )
                    .frame(width: 120, height: 180)
                    .cornerRadius(12)
                    .shadow(radius: 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            // Movie Title
                            Text(movieDetailViewModel.movieDetail?.title ?? "Loading...")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                            Spacer()
                            
                            if let movieID = movieDetailViewModel.movieDetail?.id {
                                // This is correct: Direct call on the observed object
                                Button {
                                    favoritesManager.toggleFavorite(movieID: movieID)
                                } label: {
                                    Image(systemName: favoritesManager.isFavorite(movieID: movieID) ? "star.fill" : "star") // Correct!
                                        .font(.largeTitle)
                                        .foregroundColor(favoritesManager.isFavorite(movieID: movieID) ? .yellow : .gray) // Correct!
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        // Movie Tagline (if available)
                        if let tagline = movieDetailViewModel.movieDetail?.tagline, !tagline.isEmpty {
                            Text(tagline)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }

                        // Vote Average
                        if let voteAverage = movieDetailViewModel.movieDetail?.formattedVoteAverage {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(voteAverage)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if let voteCount = movieDetailViewModel.movieDetail?.voteCount {
                                    Text("(\(voteCount) votes)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal) // Apply horizontal padding to the header

                // MARK: - Overview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(movieDetailViewModel.movieDetail?.overview ?? "No overview available.")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)

                // MARK: - Details Section (Runtime, Release Date, Genres)
                VStack(alignment: .leading, spacing: 8) {
                    // Runtime
                    if let runtime = movieDetailViewModel.movieDetail?.formattedRuntime {
                        HStack {
                            Image(systemName: "hourglass")
                            Text("Runtime: \(runtime)")
                        }
                    }

                    // Release Date
                    if let releaseDate = movieDetailViewModel.movieDetail?.releaseDate {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Release Date: \(releaseDate)")
                        }
                    }

                    // Genres
                    if let genres = movieDetailViewModel.movieDetail?.genres, !genres.isEmpty {
                        HStack(alignment: .top) {
                            Image(systemName: "tag.fill")
                            Text("Genres: \(genres.map { $0.name }.joined(separator: ", "))")
                        }
                    }
                }
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.horizontal)

                Spacer() // Pushes content to the top
            }
            // MARK: - Loading and Error States
            .overlay(
                // Display a loading indicator if data is being fetched
                Group {
                    if movieDetailViewModel.isLoading && movieDetailViewModel.movieDetail == nil {
                        ProgressView("Loading Movie Details...")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            )
            .overlay(
                // Display an error message if fetching fails
                Group {
                    if let errorMessage = movieDetailViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .multilineTextAlignment(.center)
                    }
                }
            )
        }
        .navigationTitle(movieDetailViewModel.movieDetail?.title ?? "Movie Details")
        .navigationBarTitleDisplayMode(.inline) // Keep title concise in nav bar
    }
}

// MARK: - Preview Provider
/// Provides a preview for `MovieDetailView` in Xcode's canvas.
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock MovieDetail object for preview purposes.
        let mockMovieDetail = MovieDetail(
            id: 550,
            title: "Fight Club",
            overview: "A depressed man suffering from insomnia meets a mysterious soap salesman and a reckless woman and they form an underground fight club that evolves into something much, much more.",
            posterPath: "/pB8BM7pdXLXbZVZC65NiR9CpmTv.jpg",
            backdropPath: "/oOBLgQkGjC1yUj6f8x3W8eG5qS0.jpg",
            releaseDate: "1999-10-15",
            runtime: 139,
            tagline: "Mischief. Mayhem. Soap.",
            voteAverage: 8.4,
            voteCount: 25000,
            genres: [Genre(id: 1, name: "Drama"), Genre(id: 2, name: "Thriller")],
            productionCompanies: [ProductionCompany(id: 1, name: "Regency Enterprises", logoPath: nil, originCountry: "US")],
            status: "Released"
        )

        // Embed the detail view in a NavigationView for proper previewing of navigation title.
        NavigationView {
            MovieDetailView(movieId: mockMovieDetail.id)
                // Inject the mock data directly into the ViewModel for preview.
                // This bypasses network calls in the preview canvas.
                .onAppear {
                }
        }
    }
}
