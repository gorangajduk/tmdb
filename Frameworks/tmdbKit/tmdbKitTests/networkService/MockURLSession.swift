//
//  MockURLSession.swift
//  tmdbKit
//
//  Created by Goran Gajduk on 28.5.25.
//

import Foundation
@testable import tmdbKit

/// A mock implementation of URLSessionProtocol for testing network requests.
class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    /// Initializes a mock session with predefined outcomes.
    /// - Parameters:
    ///   - data: The data to return.
    ///   - response: The URLResponse to return.
    ///   - error: The error to throw.
    init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.response = response
        self.error = error
    }

    /// Simulates a data task, returning the predefined data, response, or throwing the predefined error.
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        guard let data = data, let response = response else {
            // If no data or response is provided, throw a generic error
            throw NSError(domain: "MockURLSessionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock data or response not set."])
        }
        return (data, response)
    }
}
