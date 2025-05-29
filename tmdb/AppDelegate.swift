//
//  AppDelegate.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
#if DEBUG // Only compile this code for Debug builds
        let arguments = ProcessInfo.processInfo.arguments

        // Default mock setup for UI tests (e.g., online with mock data)
        var sessionToInject: URLSessionProtocol = URLSession.shared // Real session by default
        var networkMonitorToInject: MockNetworkMonitor? = nil
        
        if arguments.contains("-uiTestMode") {
            print("🚀 App launched in UI Test Mode.")
            // Default mock (e.g., for testTrendingMoviesScreenLoads)
            let defaultMockURLSession = MockURLSession()
            defaultMockURLSession.mockDataTaskHandler = { request in
                // Default successful response for trending movies
                let mockMovieJSON = """
                {
                    "page": 1,
                    "results": [
                        { "id": 123, "title": "Mock Movie 1", "poster_path": "/mock1.jpg", "release_date": "2023-01-01", "vote_average": 7.5, "overview": "Overview 1", "media_type": "movie", "original_language": "en", "original_title": "Mock Movie 1", "backdrop_path": "/back1.jpg", "genre_ids": [1], "popularity": 100.0, "video": false, "vote_count": 100 },
                        { "id": 456, "title": "Mock Movie 2", "poster_path": "/mock2.jpg", "release_date": "2023-02-01", "vote_average": 8.0, "overview": "Overview 2", "media_type": "movie", "original_language": "en", "original_title": "Mock Movie 2", "backdrop_path": "/back2.jpg", "genre_ids": [2], "popularity": 200.0, "video": false, "vote_count": 200 }
                    ],
                    "total_pages": 1,
                    "total_results": 2
                }
                """.data(using: .utf8)!
                let response = MockURLSession.makeMockHTTPResponse(url: request.url!, statusCode: 200)
                return (mockMovieJSON, response)
            }
            sessionToInject = defaultMockURLSession
            networkMonitorToInject = MockNetworkMonitor(connected: true, status: .satisfied)
        }

        // --- Specific mock configurations based on additional launch arguments ---
        if arguments.contains("-uiTestMode:offline") {
            print("🚀 App launched in UI Test Mode: Offline Scenario.")
            let offlineMockURLSession = MockURLSession()
            // For offline, we might not even set a data task handler if the app should just fail immediately,
            // or return a specific error if a request is made despite being "offline".
            offlineMockURLSession.mockDataTaskHandler = { request in
                throw URLError(.notConnectedToInternet) // Explicit network error
            }
            sessionToInject = offlineMockURLSession
            networkMonitorToInject = MockNetworkMonitor(connected: false, status: .unsatisfied)
        } else if arguments.contains("-uiTestMode:movieDetailMock") {
            print("🚀 App launched in UI Test Mode: Movie Detail Mock Scenario.")
            let movieDetailMockURLSession = MockURLSession()
            
            movieDetailMockURLSession.mockDataTaskHandler = { request in
                // 1. Handle the initial Trending Movies request
                if request.url?.absoluteString.contains("trending/movie") == true {
                    let mockTrendingMovieJSON = """
                                    {
                                        "page": 1,
                                        "results": [
                                            { "id": 12345, "title": "Mock Movie 1", "poster_path": "/mock1.jpg", "release_date": "2023-01-01", "vote_average": 7.5, "overview": "Overview 1", "media_type": "movie", "original_language": "en", "original_title": "Mock Movie 1", "backdrop_path": "/back1.jpg", "genre_ids": [1], "popularity": 100.0, "video": false, "vote_count": 100 },
                                            { "id": 67890, "title": "Mock Movie 2", "poster_path": "/mock2.jpg", "release_date": "2023-02-01", "vote_average": 8.0, "overview": "Overview 2", "media_type": "movie", "original_language": "en", "original_title": "Mock Movie 2", "backdrop_path": "/back2.jpg", "genre_ids": [2], "popularity": 200.0, "video": false, "vote_count": 200 }
                                        ],
                                        "total_pages": 1,
                                        "total_results": 2
                                    }
                                    """.data(using: .utf8)!
                    let response = MockURLSession.makeMockHTTPResponse(url: request.url!, statusCode: 200)
                    return (mockTrendingMovieJSON, response)
                }
                // 2. Handle the Movie Detail request
                else if request.url?.absoluteString.contains("/movie/") == true { // Check for movie detail URL (e.g., contains "/movie/12345")
                    let mockDetailJSON = """
                                    {
                                        "adult": false, "backdrop_path": "/path/to/detail_backdrop.jpg", "budget": 100000000,
                                        "genres": [{"id": 28, "name": "Action"}], "id": 12345, "imdb_id": "tt1234567",
                                        "overview": "This is the detailed overview of Mock Movie 1 for testing.",
                                        "popularity": 200.0, "poster_path": "/path/to/detail_poster.jpg",
                                        "release_date": "2023-01-01", "revenue": 500000000, "runtime": 120,
                                        "tagline": "A truly mock-tastic film!", "title": "Mock Movie 1 Detail Screen",
                                        "video": false, "vote_average": 8.5, "vote_count": 200
                                    }
                                    """.data(using: .utf8)!
                    let response = MockURLSession.makeMockHTTPResponse(url: request.url!, statusCode: 200)
                    return (mockDetailJSON, response)
                }
                // 3. Fallback for any other requests (e.g., images, genre lists, search if not mocked elsewhere)
                print("MOCK NetworkService: No specific mock handler for URL: \(request.url?.absoluteString ?? "nil")")
                return (Data(), MockURLSession.makeMockHTTPResponse(url: request.url!, statusCode: 404))
            }
            sessionToInject = movieDetailMockURLSession
            networkMonitorToInject = MockNetworkMonitor(connected: true, status: .satisfied)
        }
        
        // Finally, inject the configured mocks into NetworkService.shared
        if let nm = networkMonitorToInject { // Safely unwrap mockNetworkMonitor if it's optional
            NetworkService.shared._testOnly_inject(
                urlSession: sessionToInject,
                networkMonitor: nm
            )
        } else {
            // If no specific mock network monitor was set, ensure we're still injecting something
            NetworkService.shared._testOnly_inject(
                urlSession: sessionToInject,
                networkMonitor: NetworkMonitor.shared
            )
        }
#endif
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

