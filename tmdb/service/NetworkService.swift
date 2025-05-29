//
//  NetworkService.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation
import Network // Required for NetworkMonitor

/// Defines custom errors that can occur during network operations.
enum NetworkError: Error, LocalizedError, Equatable {
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

    /// Indicates that the app is offline and no cached data is available for the requested endpoint.
    case offlineAndNoCache

    // MARK: - Equatable Conformance
    // This allows us to compare two NetworkError instances.
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.offlineAndNoCache, .offlineAndNoCache):
            return true

        case let (.requestFailed(lhsError), .requestFailed(rhsError)),
             let (.decodingFailed(lhsError), .decodingFailed(rhsError)):
            // Compare by localizedDescription for general errors if underlying error types are not comparable
            return lhsError.localizedDescription == rhsError.localizedDescription

        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode

        default:
            return false // All other combinations are not equal
        }
    }

    // Provides a localized description for each error, useful for user-facing alerts.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .requestFailed(let error):
            // Check for specific NWError codes for better user feedback
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return "You are not connected to the internet."
                case .timedOut:
                    return "The network request timed out."
                case .cannotConnectToHost:
                    return "Could not connect to the server."
                default:
                    break
                }
            }
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server returned an error with status code: \(statusCode)."
        case .offlineAndNoCache:
            return "You are currently offline and no cached data is available for this content."
        }
    }
}

/// A singleton class responsible for handling all network requests to The MovieDB API.
/// It uses URLSession with async/await for modern, clean asynchronous operations.
/// This version includes basic offline mode capabilities by leveraging network connectivity monitoring and caching.
class NetworkService {
    // Make the shared instance a 'var' in DEBUG builds so it can be replaced by a mock.
    // In release builds, it remains a 'let' constant for performance and immutability.
    #if DEBUG
    static var shared = NetworkService()
    #else
    /// The shared singleton instance of `NetworkService`.
    /// This provides a convenient global access point for making network requests.
    static let shared = NetworkService()
    #endif
    
    // Changed to 'internal var' in DEBUG and 'private let' in RELEASE
    // and crucially, the type is now `NetworkMonitorProtocol`
    #if DEBUG
    internal var urlSession: URLSessionProtocol
    internal var networkMonitor: NetworkMonitorProtocol
    internal var cacheManager: CacheManager
    #else
    /// The URLSession instance used for making network requests.
    private let urlSession: URLSessionProtocol
    /// The network connectivity monitor, used to check online/offline status.
    private let networkMonitor: NetworkMonitorProtocol
    /// The cache manager, used to store and retrieve network responses locally.
    private let cacheManager: CacheManager
    #endif

    /// Private initializer to ensure that `NetworkService` can only be instantiated
    /// through its `shared` singleton property, enforcing the singleton pattern.
    /// This initializer takes dependencies to allow for mocking in tests.
    init(urlSession: URLSessionProtocol = URLSession.shared,
         networkMonitor: NetworkMonitorProtocol = NetworkMonitor.shared,
         cacheManager: CacheManager = .shared) {
        self.urlSession = urlSession
        self.networkMonitor = networkMonitor
        self.cacheManager = cacheManager
    }

    /// Performs a generic network request to a specified API endpoint and decodes the response.
    /// This method first checks network connectivity. If offline, it attempts to serve cached data.
    /// - Parameters:
    ///   - endpoint: The specific API endpoint path (e.g., "/trending/movie/day").
    /// - Returns: An object of type `T` (which must conform to `Codable`) decoded from the API response or cache.
    /// - Throws: A `NetworkError` if the URL is invalid, the request fails, the response is invalid,
    ///   the server returns an error status, decoding fails, or if offline with no cached data.
    func request<T: Codable>(endpoint: String) async throws -> T {
        // Step 1: Check network connectivity
        if !networkMonitor.isConnected {
            print("NetworkService: Device is offline. Attempting to retrieve data from cache for endpoint: \(endpoint)")
            if let cachedData = cacheManager.retrieveData(for: endpoint) {
                print("NetworkService: Found cached data. Attempting to decode...")
                do {
                    // Try to decode the cached data into the expected type
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601 // Adjust if your API dates are different
                    let decodedObject = try decoder.decode(T.self, from: cachedData)
                    print("NetworkService: Successfully decoded and returned cached data for endpoint: \(endpoint)")
                    return decodedObject
                } catch {
                    // If cached data is found but cannot be decoded (e.g., corrupted, outdated model),
                    // log the error and indicate no usable cache is available.
                    print("NetworkService: Error decoding cached data for \(endpoint): \(error.localizedDescription).")
                    throw NetworkError.offlineAndNoCache
                }
            } else {
                // If offline and no cache is available, throw an error
                print("NetworkService: No cached data found for endpoint: \(endpoint). Cannot fulfill request while offline.")
                throw NetworkError.offlineAndNoCache
            }
        }

        // Step 2: If online, proceed with the actual network request
        guard let url = URL(string: Constants.tmdbBaseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Explicitly set the HTTP method.

        do {
            let (data, response) = try await urlSession.data(for: request, delegate: nil)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("NetworkService: Server Error: Status Code \(httpResponse.statusCode), Data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Set date decoding strategy if your API returns dates in this format

            let decodedObject = try decoder.decode(T.self, from: data)

            // Step 3: Successfully received data from the network, now cache it
            cacheManager.storeData(data, for: endpoint)
            print("NetworkService: Successfully fetched data from network and cached for endpoint: \(endpoint)")

            return decodedObject
        } catch {
            // Catch and re-throw custom NetworkErrors or wrap system errors
            if error is NetworkError {
                throw error // Re-throw our custom errors directly
            } else if let decodingError = error as? DecodingError {
                throw NetworkError.decodingFailed(decodingError) // Catch decoding errors specifically
            } else {
                throw NetworkError.requestFailed(error) // Wrap any other system-level errors (e.g., URLSession errors)
            }
        }
    }

    /// Fetches a list of trending movies from The MovieDB API for a specific page.
    /// This uses the `trendingMovies` endpoint defined in `Constants.Endpoint`.
    ///
    /// - Parameter page: The page number of trending movies to fetch.
    /// - Returns: An array of `Movie` objects.
    /// - Throws: A `NetworkError` if the network request fails or decoding is unsuccessful.
    func fetchTrendingMovies(page: Int) async throws -> TrendingMoviesResponse {
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
    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
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
    func searchMovies(query: String, page: Int) async throws -> TrendingMoviesResponse {
        let endpoint = Constants.Endpoint.searchMovies(query: query, page: page)
        let response: TrendingMoviesResponse = try await request(endpoint: endpoint)
        return response
    }
    
#if DEBUG
    func _testOnly_inject(urlSession: URLSessionProtocol,
                          networkMonitor: NetworkMonitorProtocol) {
        NetworkService.shared = NetworkService(urlSession: urlSession,
                                               networkMonitor: networkMonitor,
                                               cacheManager: CacheManager.shared)
        print("NetworkService: Injected mock dependencies for testing.")
    }
#endif
}
