//
//  Untitled.swift
//  tmdb
//
//  Created by Goran Gajduk on 28.5.25.
//

import Foundation

/// A manager class responsible for storing and retrieving cached network data.
/// It uses the app's Caches directory to save raw Data from API responses.
class CacheManager {
    /// The shared singleton instance of `CacheManager`.
    /// Provides a convenient global access point for caching operations.
    static let shared = CacheManager()

    private let fileManager = FileManager.default
    private let cacheDirectoryName = "NetworkServiceCache"

    /// Computes the URL for the dedicated cache directory.
    /// This ensures our cached data is organized within the app's Caches folder.
    private var cacheDirectory: URL {
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            // This should ideally never fail in a running app.
            fatalError("Could not access Caches directory for the current user domain.")
        }
        return cachesDirectory.appendingPathComponent(cacheDirectoryName, isDirectory: true)
    }

    /// Private initializer to enforce the singleton pattern.
    /// It ensures that the dedicated cache directory exists when the manager is initialized.
    private init() {
        // Check if the cache directory already exists.
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                // Create the directory if it doesn't exist, including any necessary intermediate directories.
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Cache directory created at: \(cacheDirectory.path)")
            } catch {
                // Log any errors encountered during directory creation.
                print("Error creating cache directory at \(cacheDirectory.path): \(error.localizedDescription)")
            }
        } else {
            print("Cache directory already exists at: \(cacheDirectory.path)")
        }
    }

    /// Generates a unique, file-system safe filename for a given API endpoint.
    /// This simple hashing ensures that different endpoints map to different files.
    /// Note: For more complex scenarios, consider more robust hashing or explicit naming.
    private func fileName(for endpoint: String) -> String {
        // Replace characters that might be problematic in filenames (e.g., '/', '?', '&')
        let safeEndpoint = endpoint
            .replacingOccurrences(of: "/", with: "_slash_")
            .replacingOccurrences(of: "?", with: "_qmark_")
            .replacingOccurrences(of: "&", with: "_amp_")
            .replacingOccurrences(of: "=", with: "_eq_") // Also handle equals sign
            .replacingOccurrences(of: ":", with: "_colon_") // And colon

        // Use the hash value of the "safe" endpoint string for the filename, appending .json
        return "\(safeEndpoint.hashValue).json"
    }

    /// Stores raw `Data` (e.g., JSON response) to a file in the cache directory.
    /// - Parameters:
    ///   - data: The `Data` object to be saved.
    ///   - endpoint: The API endpoint string, used to derive the filename.
    func storeData(_ data: Data, for endpoint: String) {
        let fileURL = cacheDirectory.appendingPathComponent(fileName(for: endpoint))
        do {
            try data.write(to: fileURL)
            print("Successfully cached data for endpoint: \(endpoint) at \(fileURL.lastPathComponent)")
        } catch {
            print("Error saving data to cache for \(endpoint) at \(fileURL.path): \(error.localizedDescription)")
        }
    }

    /// Retrieves cached `Data` for a given API endpoint.
    /// - Parameter endpoint: The API endpoint string, used to derive the filename.
    /// - Returns: The cached `Data` if found, otherwise `nil`.
    func retrieveData(for endpoint: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(fileName(for: endpoint))
        do {
            let data = try Data(contentsOf: fileURL)
            print("Successfully retrieved cached data for endpoint: \(endpoint) from \(fileURL.lastPathComponent)")
            return data
        } catch {
            print("No cached data found or error retrieving for \(endpoint) at \(fileURL.path): \(error.localizedDescription)")
            return nil
        }
    }

    /// Clears the entire cache by removing the dedicated cache directory.
    /// It then recreates the directory to prepare for new caching.
    func clearCache() {
        do {
            if fileManager.fileExists(atPath: cacheDirectory.path) {
                try fileManager.removeItem(at: cacheDirectory)
                print("Cache directory removed: \(cacheDirectory.path)")
            }
            // Recreate the directory to ensure it's ready for future caching.
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            print("Cache cleared and directory recreated.")
        } catch {
            print("Error clearing cache at \(cacheDirectory.path): \(error.localizedDescription)")
        }
    }
}
