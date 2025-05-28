//
//  NetworkService.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation

/// Defines custom errors that can occur during network operations.
public enum NetworkError: Error, LocalizedError, Equatable {
    /// Indicates that the URL constructed for the request was invalid.
    case invalidURL
    
    /// Wraps an underlying error from the URLSession task, indicating a general request failure.
    case requestFailed(Error)
    
    /// Occurs when the server response is not a valid HTTPURLResponse.
    case invalidResponse
    
    /// Indicates an error during the JSON decoding process.
    case decodingFailed(Error)
    
    /// Signifies a server-side error, including the HTTP status code received.
    case serverError(statusCode: Int)
    
    // MARK: - Equatable Conformance
    // This allows us to compare two NetworkError instances.
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
            (.invalidResponse, .invalidResponse):
            return true
            
        case let (.requestFailed(lhsError), .requestFailed(rhsError)),
            let (.decodingFailed(lhsError), .decodingFailed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
            
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
            
        default:
            return false
        }
    }
    
    // Provides a localized description for each error, useful for user-facing alerts.
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server returned an error with status code: \(statusCode)."
        }
    }
}

/// A singleton class responsible for handling all network requests to The MovieDB API.
/// It uses URLSession with async/await for modern, clean asynchronous operations.
public class NetworkService {
    /// The shared singleton instance of `NetworkService`.
    /// This provides a convenient global access point for making network requests.
    public static let shared = NetworkService()
    
    /// The URLSession instance used for making network requests.
    private let urlSession: URLSessionProtocol
    
    /// Private initializer to ensure that `NetworkService` can only be instantiated
    /// through its `shared` singleton property, enforcing the singleton pattern.
    /// This initializer takes a URLSessionProtocol to allow for mocking in tests.
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    /// Performs a generic network request to a specified API endpoint and decodes the response.
    /// - Parameters:
    ///   - endpoint: The specific API endpoint path (e.g., "/trending/movie/day").
    /// - Returns: An object of type `T` (which must conform to `Codable`) decoded from the API response.
    /// - Throws: A `NetworkError` if the URL is invalid, the request fails, the response is invalid,
    ///   the server returns an error status, or decoding fails.
    public func request<T: Codable>(endpoint: String) async throws -> T {
        // Construct the full URL using the base URL and the provided endpoint.
        guard let url = URL(string: Constants.tmdbBaseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        // Create a URLRequest object, initially configured for a GET request.
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Explicitly set the HTTP method.
        
        do {
            // Perform the network request using URLSession's async/await data(for:) method.
            // This suspends the task until the request completes.
            let (data, response) = try await urlSession.data(for: request,
                                                             delegate: nil)
            
            // Attempt to cast the URLResponse to HTTPURLResponse to access status codes.
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Check if the HTTP status code indicates success (200-299 range).
            guard (200...299).contains(httpResponse.statusCode) else {
                // Log server error details for debugging.
                print("Server Error: Status Code \(httpResponse.statusCode), Data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            // Initialize a JSONDecoder to transform JSON data into Swift Codable objects.
            let decoder = JSONDecoder()
            // Set the date decoding strategy if your API returns dates in a specific format (e.g., ISO 8601).
            // Adjust this if The MovieDB API uses a different date format for its dates.
            decoder.dateDecodingStrategy = .iso8601 // Example: For "2025-05-27T10:00:00Z"
            
            // Attempt to decode the received data into the target Codable type `T`.
            let decodedObject = try decoder.decode(T.self, from: data)
            return decodedObject
        } catch {
            // Catch any errors that occurred during the network request or decoding.
            // Re-throw custom NetworkErrors directly, or wrap other errors as requestFailed.
            if error is NetworkError {
                throw error // Re-throw our custom errors directly
            } else if let decodingError = error as? DecodingError {
                // Catch decoding errors specifically
                throw NetworkError.decodingFailed(decodingError)
            } else {
                // Wrap any other system-level errors (e.g., no internet connection)
                throw NetworkError.requestFailed(error)
            }
        }
    }
    
    /// Fetches a list of trending movies from The MovieDB API for a specific page.
    /// This uses the `trendingMovies` endpoint defined in `Constants.Endpoint`.
    ///
    /// - Parameter page: The page number of trending movies to fetch.
    /// - Returns: An array of `Movie` objects.
    /// - Throws: A `NetworkError` if the network request fails or decoding is unsuccessful.
    public func fetchTrendingMovies(page: Int) async throws -> TrendingMoviesResponse {
        let endpoint = Constants.Endpoint.trendingMovies(page: page)
        let response: TrendingMoviesResponse = try await request(endpoint: endpoint)
        return response
    }
    
    /// Fetches detailed information for a specific movie from The MovieDB API.
    /// This uses the `movieDetails` endpoint defined in `Constants.Endpoint`.
    ///
    /// - Parameter id: The unique identifier of the movie to fetch details for.
    /// - Returns: A `MovieDetail` object containing extensive information about the movie.
    /// - Throws: A `NetworkError` if the network request fails or decoding is unsuccessful.
    public func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        let endpoint = Constants.Endpoint.movieDetails(id: id)
        return try await request(endpoint: endpoint)
    }
    
    /// Searches for movies based on a query string from The MovieDB API.
    /// This uses the `searchMovies` endpoint defined in `Constants.Endpoint`.
    ///
    /// - Parameters:
    ///   - query: The search term for movies.
    ///   - page: The page number of search results to fetch.
    /// - Returns: An array of `Movie` objects matching the search query.
    /// - Throws: A `NetworkError` if the network request fails or decoding is unsuccessful.
    public func searchMovies(query: String, page: Int) async throws -> TrendingMoviesResponse {
        let endpoint = Constants.Endpoint.searchMovies(query: query, page: page)
        let response: TrendingMoviesResponse = try await request(endpoint: endpoint)
        return response
    }
}
