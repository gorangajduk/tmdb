//
//  URLSessionProtocol.swift
//  tmdb
//
//  Created by Goran Gajduk on 28.5.25.
//


import Foundation

/// A protocol to make URLSession testable by allowing mocking.
/// URLSession will conform to this protocol via an extension.
protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

// Extend URLSession to conform to our protocol, enabling dependency injection.
extension URLSession: URLSessionProtocol {
    // The default implementation already exists for URLSession.
    // We just declare its conformance.
}
