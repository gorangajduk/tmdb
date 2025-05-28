//
//  Untitled.swift
//  tmdbKit
//
//  Created by Goran Gajduk on 28.5.25.
//

import Testing // Swift Testing framework
import Foundation // For UserDefaults, JSONEncoder/Decoder, Set, Data
@testable import tmdbKit

@MainActor
struct FavoriteMoviesManagerTests {
    // Get the singleton instance of the manager
    let manager = FavoriteMoviesManager.shared
    
    // MARK: - Setup and Teardown for Test Isolation
    
    init() {
        manager._resetStateForTesting()
        #expect(manager.favoriteMovieIDs.isEmpty, "Favorites should be empty after reset")
        
        // Use manager.testFavoritesKey here
        #expect(UserDefaults.standard.data(forKey: manager.testFavoritesKey) == nil || (try? JSONDecoder().decode(Set<Int>.self, from: UserDefaults.standard.data(forKey: manager.testFavoritesKey)!))?.isEmpty == true, "UserDefaults should be empty after reset")
    }
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization_noSavedFavorites() async {
        // Given: setUp ensures no favorites are saved
        // When: Manager is accessed (happens implicitly via 'manager' property)
        // Then: favoriteMovieIDs should be empty
        #expect(manager.favoriteMovieIDs.isEmpty, "Initial favorites should be empty when none are saved")
        #expect(manager.isFavorite(movieID: 101) == false, "Movie 101 should not be favorite initially")
    }

    @Test func testInitialization_withSavedFavorites() async throws {
        // Given: Some favorites are manually saved to UserDefaults
        let movieID1 = 1
        let movieID2 = 2
        let savedIDs: Set<Int> = [movieID1, movieID2]

        // Manually encode and save to UserDefaults, simulating a previous app session
        let encodedData = try JSONEncoder().encode(savedIDs)
        UserDefaults.standard.set(encodedData, forKey: manager.testFavoritesKey)

        manager.loadFavoritesForTesting()

        // Then: favoriteMovieIDs should contain the previously saved IDs
        #expect(manager.favoriteMovieIDs == savedIDs, "Favorites should load correctly from UserDefaults")
        #expect(manager.isFavorite(movieID: movieID1) == true, "Movie ID 1 should be favorite after loading")
        #expect(manager.isFavorite(movieID: movieID2) == true, "Movie ID 2 should be favorite after loading")
        #expect(manager.isFavorite(movieID: 3) == false, "Movie ID 3 should not be favorite after loading")
    }

    @Test func testInitialization_withMalformedSavedData() async throws {
        // Given: Malformed data is saved to UserDefaults (e.g., not a valid JSON set)
        let malformedData = Data("this is not JSON".utf8)
        UserDefaults.standard.set(malformedData, forKey: manager.testFavoritesKey)

        // When: Manager's state is reset and forced to reload
        manager._resetStateForTesting()

        // Then: It should gracefully handle the error and result in an empty set
        #expect(manager.favoriteMovieIDs.isEmpty, "Malformed data should result in empty favorites")
    }

    // MARK: - Toggle Favorite Tests

    @Test func testToggleFavorite_addMovie() async throws {
        let movieID = 123

        // When: Toggle to add a movie
        manager.toggleFavorite(movieID: movieID)

        // Then: The movie should be in favorites
        #expect(manager.favoriteMovieIDs.contains(movieID), "Favorites should contain the added movie ID")
        #expect(manager.favoriteMovieIDs.count == 1, "Favorites count should be 1 after adding one movie")
        #expect(manager.isFavorite(movieID: movieID) == true, "isFavorite should return true for the added movie")

        // Verify persistence: Check if the ID is saved in UserDefaults
        let data = UserDefaults.standard.data(forKey: manager.testFavoritesKey)
        #expect(data != nil, "Data should be saved in UserDefaults")
        let decodedIDs = try JSONDecoder().decode(Set<Int>.self, from: data!)
        #expect(decodedIDs.contains(movieID), "Saved UserDefaults should contain the added movie ID")
    }

    @Test func testToggleFavorite_removeMovie() async throws {
        let movieID = 456

        // Given: Movie is already a favorite
        manager.toggleFavorite(movieID: movieID) // Add it first
        #expect(manager.isFavorite(movieID: movieID), "Precondition: Movie should be favorite before removal test")

        // When: Toggle to remove the movie
        manager.toggleFavorite(movieID: movieID)

        // Then: The movie should not be in favorites
        #expect(!manager.favoriteMovieIDs.contains(movieID), "Favorites should not contain the removed movie ID")
        #expect(manager.favoriteMovieIDs.isEmpty, "Favorites should be empty after removing the only movie")
        #expect(manager.isFavorite(movieID: movieID) == false, "isFavorite should return false for the removed movie")

        // Verify persistence: Check if the ID is removed from UserDefaults
        let data = UserDefaults.standard.data(forKey: manager.testFavoritesKey)
        #expect(data != nil, "Data should still exist in UserDefaults (possibly empty set)")
        let decodedIDs = try JSONDecoder().decode(Set<Int>.self, from: data!)
        #expect(!decodedIDs.contains(movieID), "Saved UserDefaults should not contain the removed movie ID")
        #expect(decodedIDs.isEmpty, "Saved UserDefaults set should be empty")
    }

    @Test func testToggleFavorite_multipleMovies() async {
        let movieID1 = 100
        let movieID2 = 200
        let movieID3 = 300

        manager.toggleFavorite(movieID: movieID1)
        manager.toggleFavorite(movieID: movieID2)
        #expect(manager.favoriteMovieIDs == Set([movieID1, movieID2]), "Should contain movie1 and movie2")

        manager.toggleFavorite(movieID: movieID3)
        #expect(manager.favoriteMovieIDs == Set([movieID1, movieID2, movieID3]), "Should contain movie1, movie2, and movie3")

        manager.toggleFavorite(movieID: movieID1) // Remove movie1
        #expect(manager.favoriteMovieIDs == Set([movieID2, movieID3]), "Should contain movie2 and movie3 after removing movie1")

        manager.toggleFavorite(movieID: movieID2) // Remove movie2
        #expect(manager.favoriteMovieIDs == Set([movieID3]), "Should contain movie3 after removing movie2")

        manager.toggleFavorite(movieID: movieID3) // Remove movie3
        #expect(manager.favoriteMovieIDs.isEmpty, "Should be empty after removing all movies")
    }

    // MARK: - isFavorite Tests

    @Test func testIsFavorite() async {
        let favoriteMovieID = 789
        let nonFavoriteMovieID = 999

        // Initially not a favorite
        #expect(manager.isFavorite(movieID: favoriteMovieID) == false, "Initially, movie should not be favorite")
        #expect(manager.isFavorite(movieID: nonFavoriteMovieID) == false, "Initially, another movie should not be favorite")

        // Add to favorites
        manager.toggleFavorite(movieID: favoriteMovieID)
        #expect(manager.isFavorite(movieID: favoriteMovieID) == true, "Movie should be favorite after adding")
        #expect(manager.isFavorite(movieID: nonFavoriteMovieID) == false, "Other movie should still not be favorite")

        // Remove from favorites
        manager.toggleFavorite(movieID: favoriteMovieID)
        #expect(manager.isFavorite(movieID: favoriteMovieID) == false, "Movie should not be favorite after removal")
    }
}
