//
//  Models.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation

/// Represents the top-level response structure when fetching a list of trending movies from The MovieDB API.
/// Conforms to `Codable` to facilitate easy decoding from JSON data.
struct TrendingMoviesResponse: Codable {
    /// The current page number of the results.
    let page: Int
    
    /// An array containing the `Movie` objects for the current page.
    let results: [Movie]
    
    /// The total number of pages available for the given query.
    let totalPages: Int
    
    /// The total number of results available for the given query.
    let totalResults: Int

    /// Defines custom mapping between JSON keys (snake_case) and Swift property names (camelCase).
    /// This is necessary because The MovieDB API uses snake_case for some keys.
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

/// Represents a single movie entity, conforming to `Codable` for JSON decoding
/// and `Identifiable` for use in SwiftUI lists and other identifiable views.
struct Movie: Codable, Identifiable {
    /// The unique identifier for the movie. Conforming to `Identifiable` protocol.
    let id: Int
    
    /// The title of the movie.
    let title: String
    
    /// A brief overview or synopsis of the movie.
    let overview: String
    
    /// The path to the movie's poster image, relative to the base image URL.
    /// It's optional as some movies might not have a poster.
    let posterPath: String?
    
    /// The release date of the movie. It's optional as some entries might lack this data.
    let releaseDate: String?
    
    // MARK: - Extended Properties for Detail Screen (Future Use)
    
    /// The average vote score for the movie, typically on a scale of 0-10. Optional.
    let voteAverage: Double?
    
    /// The total number of votes the movie has received. Optional.
    let voteCount: Int?

    // MARK: - Computed Properties for Image URLs

    /// A computed property that constructs the full URL for the movie's poster image,
    /// suitable for a small display (e.g., in a collection view cell).
    /// Returns `nil` if `posterPath` is not available.
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.small.rawValue)\(path)")
    }

    /// A computed property that constructs the full URL for the movie's poster image,
    /// suitable for a larger display (e.g., in the detail screen).
    /// Returns `nil` if `posterPath` is not available.
    var detailPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.medium.rawValue)\(path)")
    }

    /// Defines custom mapping between JSON keys (snake_case) and Swift property names (camelCase).
    /// This is necessary for properties whose names differ from the API's JSON keys.
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
