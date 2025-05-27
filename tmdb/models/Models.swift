//
//  Models.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation

// MARK: - Trending Movies Response and Movie Models

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
    
    // MARK: - Extended Properties (Common to both Movie and MovieDetail if needed, but primary focus is for detail)
    
    /// The average vote score for the movie, typically on a scale of 0-10. Optional.
    let voteAverage: Double?
    
    /// The total number of votes the movie has received. Optional.
    let voteCount: Int?

    // MARK: - Computed Properties for Image URLs

    /// Returns the URL for a very low-resolution thumbnail poster image.
    /// This is intended for initial display and quick loading.
    var thumbnailPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.thumbnail.rawValue)\(path)")
    }
    
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

// MARK: - Movie Detail Model

/// Represents the detailed information for a single movie from The MovieDB API.
/// This structure includes more extensive data than the basic `Movie` model.
struct MovieDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String? // Can be null for some entries
    let posterPath: String?
    let backdropPath: String? // For a larger background image
    let releaseDate: String?
    let runtime: Int? // In minutes
    let tagline: String? // Short, catchy phrase
    let voteAverage: Double?
    let voteCount: Int?
    let genres: [Genre]?
    let productionCompanies: [ProductionCompany]?
    let status: String? // e.g., "Released", "In Production"
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.small.rawValue)\(path)")
    }
    
    var detailPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.medium.rawValue)\(path)")
    }

    var backdropThumbnailURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.small.rawValue)\(path)") // Use original or w780 for backdrop
    }
    
    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.original.rawValue)\(path)") // Use original or w780 for backdrop
    }

    var formattedRuntime: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var formattedVoteAverage: String {
        guard let average = voteAverage else { return "N/A" }
        return String(format: "%.1f", average)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, overview, tagline, runtime, status, genres
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case productionCompanies = "production_companies"
    }
}

/// Represents a genre associated with a movie.
struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

/// Represents a production company associated with a movie.
struct ProductionCompany: Codable, Identifiable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}
