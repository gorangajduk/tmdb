//
//  FavoriteMoviesManager+Testing.swift.swift
//  tmdbKit
//
//  Created by Goran Gajduk on 28.5.25.
//

import Foundation
import Combine
@testable import tmdbKit

extension FavoriteMoviesManager {
    // Expose the 'favoritesKey' for testing purposes.
    // This allows tests to refer to the manager's actual UserDefaults key
    // without hardcoding the string "favoriteMovieIDs" in the test file.
    internal var testFavoritesKey: String {
        return favoritesKey // Access the private 'favoritesKey' from within the extension
    }
    
    // Expose loadFavorites for testing purposes (to simulate a fresh load after clearing UserDefaults)
    @MainActor
    internal func loadFavoritesForTesting() {
        self.loadFavorites()
    }
    
    // Resets the manager's state and clears UserDefaults for test isolation
    @MainActor
    func _resetStateForTesting() {
        // 1. Clear the in-memory state
        favoriteMovieIDs = []

        // 2. Clear UserDefaults for the current test bundle
        // This is crucial for isolating tests using UserDefaults.standard
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            // Remove all data from the standard user defaults domain for this bundle
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }

        // 3. Force the manager to reload from the now-cleared UserDefaults
        // This simulates a "fresh start" for the singleton for the next test
        loadFavoritesForTesting() // Use the newly exposed method
    }
}
