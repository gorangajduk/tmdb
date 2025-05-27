//
//  NetworkService.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(statusCode: Int)
}

class NetworkService {
    static let shared = NetworkService() // Singleton for simplicity

    private init() {}

    func request<T: Codable>(endpoint: String) async throws -> T {
        guard let url = URL(string: Constants.tmdbBaseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Assuming GET requests for now

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server Error: Status Code \(httpResponse.statusCode), Data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Adjust if dates are different
            let decodedObject = try decoder.decode(T.self, from: data)
            return decodedObject
        } catch {
            if error is NetworkError {
                throw error // Re-throw custom errors
            } else {
                throw NetworkError.requestFailed(error)
            }
        }
    }
}
