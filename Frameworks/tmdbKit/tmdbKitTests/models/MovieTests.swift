//
//  MovieTests.swift
//  tmdbKit
//
//  Created by Goran Gajduk on 28.5.25.
//

// Import the Swift Testing framework
import Testing
import Foundation
@testable import tmdbKit

// It's good practice to group related tests. You can use a struct for this.
struct MovieTests {
    
    /// Tests the decoding of a full Movie JSON payload into the Swift struct.
    @Test func testMovieDecodingFullData() throws {
        // Arrange: Sample JSON data representing a Movie with all properties
        let jsonString = """
            {
              "id": 456,
              "title": "Decoding Test Movie",
              "overview": "An overview for a movie decoding test.",
              "poster_path": "/decoded_poster.jpg",
              "release_date": "2023-11-20",
              "vote_average": 7.9,
              "vote_count": 5000
            }
            """
        
        // Convert the JSON string to Data
        let jsonData = jsonString.data(using: .utf8)!
        
        // Act: Decode the JSON data into a Movie object
        let decoder = JSONDecoder()
        let movie = try decoder.decode(Movie.self, from: jsonData)
        
        // Assert: Verify that the decoded properties match the expected values
        #expect(movie.id == 456)
        #expect(movie.title == "Decoding Test Movie")
        #expect(movie.overview == "An overview for a movie decoding test.")
        #expect(movie.posterPath == "/decoded_poster.jpg")
        #expect(movie.releaseDate == "2023-11-20")
        #expect(movie.voteAverage == 7.9)
        #expect(movie.voteCount == 5000)
    }
    
    /// Tests the decoding of a Movie JSON payload when optional properties are missing.
    @Test func testMovieDecodingMissingOptionals() throws {
        // Arrange: Sample JSON data for Movie with several optional properties missing
        let jsonString = """
            {
              "id": 789,
              "title": "Movie with Missing Opts",
              "overview": "Short overview.",
              "poster_path": null,
              "release_date": null,
              "vote_average": null,
              "vote_count": null
            }
            """
        
        // Convert the JSON string to Data
        let jsonData = jsonString.data(using: .utf8)!
        
        // Act: Decode the JSON data into a Movie object
        let decoder = JSONDecoder()
        let movie = try decoder.decode(Movie.self, from: jsonData)
        
        // Assert: Verify that optional properties are nil
        #expect(movie.id == 789)
        #expect(movie.title == "Movie with Missing Opts")
        #expect(movie.overview == "Short overview.")
        #expect(movie.posterPath == nil)
        #expect(movie.releaseDate == nil)
        #expect(movie.voteAverage == nil)
        #expect(movie.voteCount == nil)
    }
    
    @Test // This attribute marks the function as a test case
    func testMovieInitialization() {
        // Arrange: Prepare the data for the test
        let id = 123
        let title = "Awesome Adventure"
        let overview = "A thrilling tale of daring feats."
        let posterPath = "/poster.jpg"
        let releaseDate = "2024-01-15"
        let voteAverage = 8.5
        let voteCount = 1500
        
        // Act: Create the Movie instance using the public initializer
        // This assumes you have the public initializer we discussed earlier.
        let movie = Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
        
        // Assert: Check if the properties of the movie instance match the expected values
        #expect(movie.id == id)
        #expect(movie.title == title)
        #expect(movie.overview == overview)
        #expect(movie.posterPath == posterPath)
        #expect(movie.releaseDate == releaseDate)
        #expect(movie.voteAverage == voteAverage)
        #expect(movie.voteCount == voteCount)
    }
    
    @Test
    func testMoviePosterURLConstruction() {
        // Arrange
        let posterPath = "/testPath.jpg"
        let movieWithPoster = Movie(
            id: 1,
            title: "Movie With Poster",
            overview: "Overview",
            posterPath: posterPath,
            releaseDate: nil,
            voteAverage: nil,
            voteCount: nil
        )
        
        let movieWithoutPoster = Movie(
            id: 2,
            title: "Movie Without Poster",
            overview: "Overview",
            posterPath: nil, // No poster path
            releaseDate: nil,
            voteAverage: nil,
            voteCount: nil
        )
        
        let expectedThumbnailURLString = "\(tmdbKit.Constants.tmdbImageBaseURL)\(tmdbKit.Constants.ImageSize.thumbnail.rawValue)\(posterPath)"
        let expectedPosterURLString = "\(tmdbKit.Constants.tmdbImageBaseURL)\(tmdbKit.Constants.ImageSize.small.rawValue)\(posterPath)"
        let expectedDetailPosterURLString = "\(tmdbKit.Constants.tmdbImageBaseURL)\(tmdbKit.Constants.ImageSize.medium.rawValue)\(posterPath)"
        
        // Act & Assert for movie with poster
        #expect(movieWithPoster.thumbnailPosterURL?.absoluteString == expectedThumbnailURLString)
        #expect(movieWithPoster.posterURL?.absoluteString == expectedPosterURLString)
        #expect(movieWithPoster.detailPosterURL?.absoluteString == expectedDetailPosterURLString)
        
        // Act & Assert for movie without poster
        #expect(movieWithoutPoster.thumbnailPosterURL == nil)
        #expect(movieWithoutPoster.posterURL == nil)
        #expect(movieWithoutPoster.detailPosterURL == nil)
    }
}
