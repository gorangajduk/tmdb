//
//  TrendingMoviesResponseTests.swift
//  tmdbKit
//
//  Created by Goran Gajduk on 28.5.25.
//

import Testing
import Foundation
@testable import tmdbKit

struct TrendingMoviesResponseTests {

    /// Tests the decoding of a TrendingMoviesResponse JSON payload into the Swift struct.
    @Test func testTrendingMoviesResponseDecoding() throws {
        // Arrange: Sample JSON data representing a TrendingMoviesResponse
        let jsonString = """
        {
          "page": 1,
          "results": [
            {
              "id": 1,
              "title": "Sample Movie 1",
              "overview": "Overview for sample movie 1.",
              "poster_path": "/path1.jpg",
              "release_date": "2023-01-01",
              "vote_average": 7.5,
              "vote_count": 1000
            },
            {
              "id": 2,
              "title": "Sample Movie 2",
              "overview": "Overview for sample movie 2.",
              "poster_path": "/path2.jpg",
              "release_date": "2023-02-01",
              "vote_average": 8.0,
              "vote_count": 2000
            }
          ],
          "total_pages": 5,
          "total_results": 100
        }
        """

        // Convert the JSON string to Data
        let jsonData = jsonString.data(using: .utf8)!

        // Act: Decode the JSON data into a TrendingMoviesResponse object
        let decoder = JSONDecoder()
        let response = try decoder.decode(TrendingMoviesResponse.self, from: jsonData)

        // Assert: Verify that the decoded properties match the expected values
        #expect(response.page == 1)
        #expect(response.totalPages == 5)
        #expect(response.totalResults == 100)
        #expect(response.results.count == 2)

        // Assert: Verify the first movie in the results
        let movie1 = response.results[0]
        #expect(movie1.id == 1)
        #expect(movie1.title == "Sample Movie 1")
        #expect(movie1.overview == "Overview for sample movie 1.")
        #expect(movie1.posterPath == "/path1.jpg")
        #expect(movie1.releaseDate == "2023-01-01")
        #expect(movie1.voteAverage == 7.5)
        #expect(movie1.voteCount == 1000)

        // Assert: Verify the second movie in the results
        let movie2 = response.results[1]
        #expect(movie2.id == 2)
        #expect(movie2.title == "Sample Movie 2")
        #expect(movie2.overview == "Overview for sample movie 2.")
        #expect(movie2.posterPath == "/path2.jpg")
        #expect(movie2.releaseDate == "2023-02-01")
        #expect(movie2.voteAverage == 8.0)
        #expect(movie2.voteCount == 2000)
    }

    /// Tests decoding of TrendingMoviesResponse with missing optional properties in movies.
    @Test func testTrendingMoviesResponseDecodingWithMissingOptionals() throws {
        let jsonString = """
        {
          "page": 1,
          "results": [
            {
              "id": 3,
              "title": "Movie Without Poster",
              "overview": "This movie has no poster.",
              "release_date": "2024-03-01",
              "vote_average": 6.0,
              "vote_count": 500
            },
            {
              "id": 4,
              "title": "Movie Without Date or Votes",
              "overview": "This movie is missing some data.",
              "poster_path": "/another_path.jpg"
            }
          ],
          "total_pages": 1,
          "total_results": 2
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(TrendingMoviesResponse.self, from: jsonData)

        #expect(response.page == 1)
        #expect(response.results.count == 2)

        let movie3 = response.results[0]
        #expect(movie3.id == 3)
        #expect(movie3.title == "Movie Without Poster")
        #expect(movie3.posterPath == nil)
        #expect(movie3.releaseDate == "2024-03-01")
        #expect(movie3.voteAverage == 6.0)
        #expect(movie3.voteCount == 500)

        let movie4 = response.results[1]
        #expect(movie4.id == 4)
        #expect(movie4.title == "Movie Without Date or Votes")
        #expect(movie4.posterPath == "/another_path.jpg")
        #expect(movie4.releaseDate == nil)
        #expect(movie4.voteAverage == nil)
        #expect(movie4.voteCount == nil)
    }
}
