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
    
    // This helper determines if the current build is a development build.
    // It reads the 'IsDevelopmentBuild' flag from Info.plist.
    // If the flag isn't explicitly "1", it defaults to false (production behavior).
    private static var isDevelopmentBuild: Bool = {
        guard let isDevString = Bundle.main.infoDictionary?["IsDevelopmentBuild"] as? String else {
            // If the key is missing in Info.plist, assume it's a production build (safe default)
            print("Warning: 'IsDevelopmentBuild' not found in Info.plist. Defaulting to Production environment.")
            return false
        }
        return isDevString == "1"
    }()
    
    /// The API key for The MovieDB service.
    /// It first attempts to retrieve the key from a test environment variable (for testing builds).
    /// If not found, it falls back to retrieving it from the app's `Info.plist` (for app builds).
    /// A fatal error will occur if the key is missing or empty in both scenarios.
    static let tmdbAPIKey: String = {
        // 1. Try to get the API key from a test environment variable
        if let testApiKey = ProcessInfo.processInfo.environment["TMDB_API_KEY_TEST"], !testApiKey.isEmpty {
            print("Using TMDB_API_KEY from environment variable for tests.")
            return testApiKey
        }
        
        // 2. Fallback: If not in test environment, try Info.plist (for app builds)
        guard let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String, !apiKey.isEmpty else {
            fatalError("Error: TMDB_API_KEY not found. Please set 'TMDB_API_KEY' in Info.plist (for app) or 'TMDB_API_KEY_TEST' as environment variable (for tests).")
        }
        print("Using TMDB_API_KEY from Info.plist for app build.")
        return apiKey
    }()
    
    /// The base URL for The MovieDB API. All API requests will start with this URL.
    private static let tmdbBaseURLProd = "https://api.themoviedb.org/3"
    private static let tmdbBaseURLDev = "https://api.themoviedb.org/3"
    
    // Determines the API Base URL based on the development flag
    static let tmdbBaseURL: String = {
        return Constants.isDevelopmentBuild ? tmdbBaseURLDev : tmdbBaseURLProd
    }()

    /// The base URL for fetching movie and series images from The MovieDB.
    /// Image size specifications are appended to this URL.
    static let tmdbImageBaseURLProd = "https://image.tmdb.org/t/p/"
    static let tmdbImageBaseURLDev = "https://image.tmdb.org/t/p/"
    
    // Determines the API Base URL based on the development flag
    static let tmdbImageBaseURL: String = {
        return Constants.isDevelopmentBuild ? tmdbImageBaseURLDev : tmdbImageBaseURLProd
    }()

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
    }
}
