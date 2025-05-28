//
//  FavoriteMoviesManager.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation
import Combine // For @Published and ObservableObject

/// Manages the list of favorite movie IDs using `UserDefaults` for local persistence.
/// This class is an `ObservableObject` so SwiftUI views can react to changes in favorites.
///
/// Marked with `@MainActor` to ensure all state updates and notifications happen on the main thread.
@MainActor
final public class FavoriteMoviesManager: ObservableObject {
    /// The shared singleton instance of `FavoriteMoviesManager`.
    public static let shared = FavoriteMoviesManager()

    /// A published set of movie IDs that are currently marked as favorites.
    /// Any SwiftUI view observing this property will automatically update when the set changes.
    @Published public private(set) var favoriteMovieIDs: Set<Int> = []

    /// The key used to store and retrieve favorite movie IDs from `UserDefaults`.
    private let favoritesKey = "favoriteMovieIDs"

    /// Private initializer to enforce the singleton pattern.
    private init() {
        loadFavorites() // Load favorites from UserDefaults when the manager is initialized
    }

    /// Loads the saved favorite movie IDs from `UserDefaults`.
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decodedIDs = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            self.favoriteMovieIDs = decodedIDs
            print("Loaded favorites: \(favoriteMovieIDs.count) movies")
        } else {
            print("No favorites found or failed to decode.")
            self.favoriteMovieIDs = []
        }
    }

    /// Saves the current set of favorite movie IDs to `UserDefaults`.
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteMovieIDs) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
            print("Saved favorites: \(favoriteMovieIDs.count) movies")
        } else {
            print("Failed to encode favorite movie IDs for saving.")
        }
    }

    /// Toggles the favorite status of a movie.
    /// If the movie is already a favorite, it's removed; otherwise, it's added.
    /// - Parameter movieID: The ID of the movie to toggle.
    public func toggleFavorite(movieID: Int) {
        if favoriteMovieIDs.contains(movieID) {
            favoriteMovieIDs.remove(movieID)
            print("Removed movie ID \(movieID) from favorites.")
        } else {
            favoriteMovieIDs.insert(movieID)
            print("Added movie ID \(movieID) to favorites.")
        }
        saveFavorites() // Persist changes immediately
    }

    /// Checks if a movie is currently marked as a favorite.
    /// - Parameter movieID: The ID of the movie to check.
    /// - Returns: `true` if the movie is a favorite, `false` otherwise.
    public func isFavorite(movieID: Int) -> Bool {
        return favoriteMovieIDs.contains(movieID)
    }
}
