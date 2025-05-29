//
//  NetworkMonitor.swift
//  tmdbKit
//
//  Created by Goran Gajduk on 28.5.25.
//

import Network // Import the Network framework
import Foundation // For DispatchQueue and ObservableObject
import Combine

/// A singleton class to monitor the device's network connectivity status.
/// It uses NWPathMonitor to detect changes in network paths (Wi-Fi, cellular, etc.).
public class NetworkMonitor: ObservableObject {
    /// The shared singleton instance of `NetworkMonitor`.
    /// Provides a convenient global access point for network status.
    public static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor // Monitors network paths
    private let queue = DispatchQueue(label: "NetworkMonitorQueue") // Dedicated queue for monitor updates

    /// Published property indicating if there's an active network connection.
    /// This property can be observed by SwiftUI views or other parts of your app.
    @Published public private(set) var isConnected: Bool = true // Assume connected until verified

    /// Published property indicating the specific status of the network path.
    /// Useful for more detailed checks (e.g., satisfied, unsatisfied, requiresConnection).
    @Published public private(set) var connectionStatus: NWPath.Status = .satisfied // Assume satisfied until verified

    /// Private initializer to ensure the singleton pattern.
    /// Sets up the network path monitoring.
    private init() {
        monitor = NWPathMonitor()
        // Define the handler for network path updates.
        monitor.pathUpdateHandler = { [weak self] path in
            // Ensure UI updates or updates to Published properties happen on the main thread.
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                self?.connectionStatus = path.status
                if path.status == .satisfied {
                    print("Network status: Connected")
                } else {
                    print("Network status: Disconnected")
                }
            }
        }
        // Start monitoring network changes on the dedicated queue.
        monitor.start(queue: queue)
    }

    /// Cancels the network monitor when the object is deallocated.
    deinit {
        monitor.cancel()
    }
}
