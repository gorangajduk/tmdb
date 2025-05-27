//
//  Constants.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation

/// A centralized struct to hold all static constants, API keys, and endpoint configurations
/// for The MovieDB application. This improves maintainability and prevents magic strings.
struct Constants {

    /// The API key for The MovieDB service.
    /// This value is retrieved securely from the app's `Info.plist` at runtime,
    /// which is populated from a User-Defined Build Setting in Xcode.
    /// A fatal error will occur if the key is missing or empty, ensuring critical configuration is present.
    static let tmdbAPIKey: String = {
        guard let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String, !apiKey.isEmpty else {
            fatalError("Error: TMDB_API_KEY not found in Info.plist or is empty. Please set it in your project's Build Settings.")
        }
        return apiKey
    }()

    /// The base URL for The MovieDB API. All API requests will start with this URL.
    static let tmdbBaseURL = "https://api.themoviedb.org/3"

    /// The base URL for fetching movie and series images from The MovieDB.
    /// Image size specifications are appended to this URL.
    static let tmdbImageBaseURL = "https://image.tmdb.org/t/p/"

    /// Defines standard image sizes available from The MovieDB API.
    /// These raw string values correspond to specific image width/height options.
    enum ImageSize: String {
        /// A very small image size, ideal for quick loading thumbnails (92px width).
        case thumbnail = "w92"
        /// A smaller image size, typically used for collection view cells or thumbnails (200px width).
        case small = "w200"
        /// A medium image size, suitable for detail screens or larger previews (500px width).
        case medium = "w500"
        /// The original resolution image. Use with caution due to larger file sizes.
        case original = "original"
    }

    /// Provides pre-defined API endpoints as computed properties,
    /// simplifying URL construction and ensuring consistent API key inclusion.
    enum Endpoint {
        /// Generates the endpoint for fetching trending movies for a specific day.
        /// - Parameter page: The page number of results to fetch.
        /// - Returns: A string representing the full API path for trending movies.
        static func trendingMovies(page: Int) -> String { "/trending/movie/day?api_key=\(Constants.tmdbAPIKey)&page=\(page)" }

        /// Generates the endpoint for fetching detailed information about a specific movie.
        /// - Parameter id: The unique ID of the movie.
        /// - Returns: A string representing the full API path for movie details.
        static func movieDetails(id: Int) -> String { "/movie/\(id)?api_key=\(Constants.tmdbAPIKey)" }

        /// Generates the endpoint for searching movies.
        /// - Parameters:
        ///   - query: The search query string.
        ///   - page: The page number of search results to fetch.
        /// - Returns: A string representing the full API path for movie search.
        static func searchMovies(query: String, page: Int) -> String { "/search/movie?api_key=\(Constants.tmdbAPIKey)&query=\(query)&page=\(page)" }
        // TODO: Add series search endpoint and other relevant endpoints as needed.
    }
}
