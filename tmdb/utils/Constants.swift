//
//  Constants.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation

struct Constants {
    static let tmdbAPIKey: String = {
        guard let apiKey = Bundle.main.infoDictionary?["TMDB_API_API_KEY"] as? String, !apiKey.isEmpty else {
            fatalError("Error: TMDB_API_API_KEY not found in Info.plist or is empty. Please set it in your project's Build Settings.")
        }
        return apiKey
    }()

    static let tmdbBaseURL = "https://api.themoviedb.org/3"
    static let tmdbImageBaseURL = "https://image.tmdb.org/t/p/"

    enum ImageSize: String {
        case small = "w200" // For collection view cells
        case medium = "w500" // For detail screen
        case original = "original" // If needed
    }

    // Other API endpoints
    enum Endpoint {
        static func trendingMovies(page: Int) -> String { "/trending/movie/day?api_key=\(Constants.tmdbAPIKey)&page=\(page)" }
        static func movieDetails(id: Int) -> String { "/movie/\(id)?api_key=\(Constants.tmdbAPIKey)" }
        static func searchMovies(query: String, page: Int) -> String { "/search/movie?api_key=\(Constants.tmdbAPIKey)&query=\(query)&page=\(page)" }
        // Add series endpoints later
    }
}
