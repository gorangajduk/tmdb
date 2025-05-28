//
//  NetworkServiceTests.swift
//  tmdbKit
//
//  Created by Goran Gajduk on 28.5.25.
//


import Testing
import Foundation // Needed for Data, URLResponse, etc.
@testable import tmdbKit // Essential to access NetworkService and other internal types

struct NetworkServiceTests {

    /// Tests a successful network request and subsequent decoding.
    @Test func testSuccessfulRequestAndDecoding() async throws {
        // Arrange: Prepare mock data and response for a successful scenario.
        // We'll use a simple mock Codable struct for this general request test.
        struct MockDecodable: Codable, Equatable {
            let id: Int
            let name: String
        }

        let mockJson = """
        {
          "id": 123,
          "name": "Test Item"
        }
        """
        let mockData = mockJson.data(using: .utf8)!
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.example.com/test")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!

        // Initialize NetworkService with a MockURLSession providing the mock data/response.
        let mockSession = MockURLSession(data: mockData, response: mockResponse)
        let networkService = NetworkService(urlSession: mockSession)

        // Act: Perform the network request using the service.
        let decodedObject: MockDecodable = try await networkService.request(endpoint: "/test")

        // Assert: Verify that the decoded object matches the expected values.
        #expect(decodedObject.id == 123)
        #expect(decodedObject.name == "Test Item")
    }

    /// Tests the scenario where the underlying URLSession request fails (e.g., network connectivity issues).
    @Test func testRequestFailed() async throws {
        // Arrange: Prepare a mock session that throws a network error.
        let mockError = URLError(.notConnectedToInternet)
        let mockSession = MockURLSession(error: mockError)
        let networkService = NetworkService(urlSession: mockSession)

        // Act & Assert: Expect a NetworkError.requestFailed to be thrown.
        await #expect(throws: NetworkError.requestFailed(mockError)) {
            let _: TrendingMoviesResponse = try await networkService.request(endpoint: "/trending/movie/day")
        }
    }

    /// Tests the scenario where the response is not an HTTPURLResponse.
    @Test func testInvalidResponse() async {
        // Arrange: Prepare mock data and a non-HTTP URLResponse.
        let mockData = Data("{}".utf8)
        let mockResponse = URLResponse(url: URL(string: "https://api.example.com/test")!,
                                       mimeType: nil,
                                       expectedContentLength: 0,
                                       textEncodingName: nil)

        let mockSession = MockURLSession(data: mockData, response: mockResponse)
        let networkService = NetworkService(urlSession: mockSession)

        // Act & Assert: Expect an invalidResponse error to be thrown.
        await #expect(throws: NetworkError.invalidResponse) {
            let _: TrendingMoviesResponse = try await networkService.request(endpoint: "/test")
        }
    }

    /// Tests the scenario where the server returns an error status code (e.g., 404, 500).
    @Test func testServerError() async {
        // Arrange: Prepare mock data and an HTTPURLResponse with an error status code.
        let mockData = Data("{\"success\": false, \"status_code\": 34, \"status_message\": \"The resource you requested could not be found.\" }".utf8)
        let statusCode = 404
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.example.com/test")!,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!

        let mockSession = MockURLSession(data: mockData, response: mockResponse)
        let networkService = NetworkService(urlSession: mockSession)

        // Act & Assert: Expect a serverError with the correct status code.
        await #expect(throws: NetworkError.serverError(statusCode: statusCode)) {
            let _: TrendingMoviesResponse = try await networkService.request(endpoint: "/test")
        }
    }
    
    /// Tests the scenario where decoding of the response data fails.
    @Test func testDecodingFailed() async {
        // Arrange: Provide valid HTTP response but with malformed or unexpected JSON data.
        let mockData = Data("{\"not_id\": \"not_a_number\", \"not_name\": 123}".utf8) // Data that won't decode to MockDecodable
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.example.com/test")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
        
        let mockSession = MockURLSession(data: mockData, response: mockResponse)
        let networkService = NetworkService(urlSession: mockSession)
        
        // Act & Assert: Expect a decodingFailed error.
        do {
            // Define MockDecodable here for this specific test's context
            struct MockDecodable: Codable {
                let id: Int
                let name: String
            }
            let _: MockDecodable = try await networkService.request(endpoint: "/test")
            // If execution reaches here, no error was thrown, which is unexpected for this test.
            // Using Issue.record to explicitly mark the test as failed.
            Issue.record("Expected decodingFailed error but no error was thrown.")
        } catch let error as NetworkError {
            // Check if the thrown NetworkError is the specific .decodingFailed case
            guard case .decodingFailed = error else {
                Issue.record("Expected NetworkError.decodingFailed but got different NetworkError: \(error)")
                return
            }
            // If it's NetworkError.decodingFailed, the test implicitly passes here.
            // No need for an explicit expect(true) as the absence of a record is success.
        } catch {
            // If it's not a NetworkError (e.g., a system error unrelated to our NetworkService logic), record an issue.
            Issue.record("Expected NetworkError but got unexpected error type: \(error)")
        }
    }
    
    // MARK: - Specific API Call Tests
    
    /// Tests fetching trending movies successfully.
    @Test func testFetchTrendingMoviesSuccess() async throws {
        // Arrange: Provide mock JSON data for TrendingMoviesResponse
        let mockJson = """
        {
          "page": 1,
          "results": [
            {
              "id": 1,
              "title": "Mock Movie 1",
              "overview": "Overview 1",
              "poster_path": "/p1.jpg",
              "release_date": "2023-01-01",
              "vote_average": 7.0,
              "vote_count": 100
            }
          ],
          "total_pages": 1,
          "total_results": 1
        }
        """
        let mockData = mockJson.data(using: .utf8)!
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.themoviedb.org/3/trending/movie/day?page=1")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!

        let mockSession = MockURLSession(data: mockData, response: mockResponse)
        let networkService = NetworkService(urlSession: mockSession)

        // Act
        let trendingResponse = try await networkService.fetchTrendingMovies(page: 1)

        // Assert
        #expect(trendingResponse.page == 1)
        #expect(trendingResponse.results.count == 1)
        #expect(trendingResponse.results.first?.title == "Mock Movie 1")
    }

    /// Tests fetching movie detail successfully.
    @Test func testFetchMovieDetailSuccess() async throws {
        // Arrange: Provide mock JSON data for MovieDetail
        let mockJson = """
        {
          "id": 123,
          "title": "Mock Detail Movie",
          "overview": "Detailed overview.",
          "poster_path": "/dp.jpg",
          "backdrop_path": "/db.jpg",
          "release_date": "2023-05-15",
          "runtime": 100,
          "tagline": "A tagline",
          "vote_average": 8.5,
          "vote_count": 500,
          "genres": [{"id": 1, "name": "Action"}],
          "production_companies": [],
          "status": "Released"
        }
        """
        let mockData = mockJson.data(using: .utf8)!
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.themoviedb.org/3/movie/123")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!

        let mockSession = MockURLSession(data: mockData, response: mockResponse)
        let networkService = NetworkService(urlSession: mockSession)

        // Act
        let movieDetail = try await networkService.fetchMovieDetail(id: 123)

        // Assert
        #expect(movieDetail.id == 123)
        #expect(movieDetail.title == "Mock Detail Movie")
        #expect(movieDetail.runtime == 100)
        #expect(movieDetail.genres?.first?.name == "Action")
    }

    /// Tests searching movies successfully.
    @Test func testSearchMoviesSuccess() async throws {
        // Arrange: Provide mock JSON data for TrendingMoviesResponse (used by search)
        let mockJson = """
        {
          "page": 1,
          "results": [
            {
              "id": 2,
              "title": "Search Result Movie",
              "overview": "Overview for search result",
              "poster_path": "/s1.jpg",
              "release_date": "2023-06-01",
              "vote_average": 6.5,
              "vote_count": 200
            }
          ],
          "total_pages": 1,
          "total_results": 1
        }
        """
        let mockData = mockJson.data(using: .utf8)!
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.themoviedb.org/3/search/movie?query=test&page=1")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!

        let mockSession = MockURLSession(data: mockData, response: mockResponse)
        let networkService = NetworkService(urlSession: mockSession)

        // Act
        let searchResponse = try await networkService.searchMovies(query: "test", page: 1)

        // Assert
        #expect(searchResponse.page == 1)
        #expect(searchResponse.results.count == 1)
        #expect(searchResponse.results.first?.title == "Search Result Movie")
    }
}
