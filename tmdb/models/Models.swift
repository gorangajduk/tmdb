//
//  Models.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation

struct TrendingMoviesResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable, Identifiable { // Identifiable for SwiftUI
    let id: Int
    let title: String
    let overview: String
    let posterPath: String? // Optional, as it might be null
    let releaseDate: String?
    // Add more properties as you need for the detail screen
    let voteAverage: Double?
    let voteCount: Int?

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.small.rawValue)\(path)")
    }

    var detailPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Constants.tmdbImageBaseURL)\(Constants.ImageSize.medium.rawValue)\(path)")
    }

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
