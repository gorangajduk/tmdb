//
//  Untitled.swift
//  tmdb
//
//  Created by Goran Gajduk on 29.5.25.
//

import Foundation
import Network // Required for NWPath.Status and NetworkService mocking

#if DEBUG
/// A mock implementation of `URLSessionProtocol` for UI testing.
/// This allows UI tests to provide predefined data and responses instead of making real network calls.
class MockURLSession: URLSessionProtocol {
    /// A closure that the mock session will execute when `data(for:delegate:)` is called.
    /// This allows each test to define its specific response (data, URLResponse, or error).
    var mockDataTaskHandler: ((URLRequest) throws -> (Data, URLResponse))?

    /// Conforms to `URLSessionProtocol`. Calls the `mockDataTaskHandler` to get the response.
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        guard let handler = mockDataTaskHandler else {
            throw URLError(.badServerResponse)
        }
        return try handler(request)
    }

    /// A helper method to create a simple mock HTTP URL response.
    static func makeMockHTTPResponse(url: URL, statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

// MARK: - MockNetworkMonitor

/// A mock implementation of `NetworkMonitorProtocol` for UI testing.
/// This allows UI tests to precisely control the reported network connectivity status.
/// Each instance is initialized with its desired state.
class MockNetworkMonitor: NetworkMonitorProtocol { // Conforms to the protocol
    var isConnected: Bool
    var connectionStatus: NWPath.Status

    /// Initializes the mock network monitor with a predefined connection status.
    /// - Parameters:
    ///   - connected: The initial value for `isConnected`.
    ///   - status: The initial value for `connectionStatus`.
    init(connected: Bool, status: NWPath.Status) {
        self.isConnected = connected
        self.connectionStatus = status
        print("MockNetworkMonitor initialized with isConnected=\(connected), status=\(status)")
    }
}
#endif // DEBUG
