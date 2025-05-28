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
public struct TrendingMoviesResponse: Codable {
    /// The current page number of the results.
    public let page: Int
    
    /// An array containing the `Movie` objects for the current page.
    public let results: [Movie]
    
    /// The total number of pages available for the given query.
    public let totalPages: Int
    
    /// The total number of results available for the given query.
    public let totalResults: Int

    /// Defines custom mapping between JSON keys (snake_case) and Swift property names (camelCase).
    /// This is necessary because The MovieDB API uses snake_case for some keys.
    public enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

/// Represents a single movie entity, conforming to `Codable` for JSON decoding
/// and `Identifiable` for use in SwiftUI lists and other identifiable views.
public struct Movie: Codable, Identifiable {
    /// The unique identifier for the movie. Conforming to `Identifiable` protocol.
    public let id: Int
    
    /// The title of the movie.
    public let title: String
    
    /// A brief overview or synopsis of the movie.
    public let overview: String
    
    /// The path to the movie's poster image, relative to the base image URL.
    /// It's optional as some movies might not have a poster.
    public let posterPath: String?
    
    /// The release date of the movie. It's optional as some entries might lack this data.
    public let releaseDate: String?
    
    // MARK: - Extended Properties (Common to both Movie and MovieDetail if needed, but primary focus is for detail)
    
    /// The average vote score for the movie, typically on a scale of 0-10. Optional.
    public let voteAverage: Double?
    
    /// The total number of votes the movie has received. Optional.
    public let voteCount: Int?

    // MARK: - Computed Properties for Image URLs

    /// Returns the URL for a very low-resolution thumbnail poster image.
    /// This is intended for initial display and quick loading.
    public var thumbnailPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.thumbnail.rawValue)\(path)")
    }
    
    /// A computed property that constructs the full URL for the movie's poster image,
    /// suitable for a small display (e.g., in a collection view cell).
    /// Returns `nil` if `posterPath` is not available.
    public var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.small.rawValue)\(path)")
    }

    /// A computed property that constructs the full URL for the movie's poster image,
    /// suitable for a larger display (e.g., in the detail screen).
    /// Returns `nil` if `posterPath` is not available.
    public var detailPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.medium.rawValue)\(path)")
    }
    
    // MARK: - Explicit Public Initializer
    /// Creates a new Movie instance.
    public init(id: Int,
                title: String,
                overview: String,
                posterPath: String?,
                releaseDate: String?,
                voteAverage: Double?,
                voteCount: Int?) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
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
public struct MovieDetail: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let overview: String? // Can be null for some entries
    public let posterPath: String?
    public let backdropPath: String? // For a larger background image
    public let releaseDate: String?
    public let runtime: Int? // In minutes
    public let tagline: String? // Short, catchy phrase
    public let voteAverage: Double?
    public let voteCount: Int?
    public let genres: [Genre]?
    public let productionCompanies: [ProductionCompany]?
    public let status: String? // e.g., "Released", "In Production"
    
    public var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.small.rawValue)\(path)")
    }
    
    public var detailPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.medium.rawValue)\(path)")
    }

    public var backdropThumbnailURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.small.rawValue)\(path)") // Use original or w780 for backdrop
    }
    
    public var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.original.rawValue)\(path)") // Use original or w780 for backdrop
    }

    public var formattedRuntime: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    public var formattedVoteAverage: String {
        guard let average = voteAverage else { return "N/A" }
        return String(format: "%.1f", average)
    }

    // MARK: - Explicit Public Initializer
    /// Creates a new MovieDetails instance.
    public init(id: Int,
                title: String,
                overview: String? = nil,
                posterPath: String? = nil,
                backdropPath: String? = nil,
                releaseDate: String? = nil,
                runtime: Int? = nil,
                tagline: String? = nil,
                voteAverage: Double? = nil,
                voteCount: Int? = nil,
                genres: [Genre]? = nil,
                productionCompanies: [ProductionCompany]? = nil,
                status: String? = nil) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.tagline = tagline
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.genres = genres
        self.productionCompanies = productionCompanies
        self.status = status
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
public struct Genre: Codable, Identifiable {
    public let id: Int
    public let name: String
    
    // MARK: - Explicit Public Initializer
    /// Creates a new Genre instance.
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

/// Represents a production company associated with a movie.
public struct ProductionCompany: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let logoPath: String?
    public let originCountry: String?
    
    // MARK: - Explicit Public Initializer
    /// Creates a new ProductionCompany instance.
    public init(id: Int, name: String, logoPath: String? = nil, originCountry: String? = nil) {
        self.id = id
        self.name = name
        self.logoPath = logoPath
        self.originCountry = originCountry
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}
