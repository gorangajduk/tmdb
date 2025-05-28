//
//  MovieDetailTests.swift
//  tmdbKit
//
//  Created by Goran Gajduk on 28.5.25.
//


import Testing
import Foundation
@testable import tmdbKit

struct MovieDetailTests {
    
    /// Tests the decoding of a comprehensive MovieDetail JSON payload into the Swift struct.
    @Test func testMovieDetailDecodingFullData() throws {
        // Arrange: Sample JSON data representing a MovieDetail with all properties
        let jsonString = """
        {
          "id": 550,
          "title": "Fight Club",
          "overview": "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground 'fight clubs' forming in every town, until an eccentric devotee's plan to destroy corporate America threatens to tear them apart.",
          "poster_path": "/pB8BM7pdXLXbZHQPHGygzLDxaNy.jpg",
          "backdrop_path": "/8uO0gUM8YaSdeEOEULYLdAB7Pyl.jpg",
          "release_date": "1999-10-15",
          "runtime": 139,
          "tagline": "Mischief. Mayhem. Soap.",
          "vote_average": 8.433,
          "vote_count": 27289,
          "genres": [
            {
              "id": 18,
              "name": "Drama"
            },
            {
              "id": 53,
              "name": "Thriller"
            }
          ],
          "production_companies": [
            {
              "id": 508,
              "logo_path": "/7PzMZTzU9KzH5yB8zZf0T0.png",
              "name": "Regency Enterprises",
              "origin_country": "US"
            },
            {
              "id": 711,
              "logo_path": "/tEiFY5PPEr3sM4WjC6X8YgB4ZfW.png",
              "name": "Fox 2000 Pictures",
              "origin_country": "US"
            }
          ],
          "status": "Released"
        }
        """
        
        // Convert the JSON string to Data
        let jsonData = jsonString.data(using: .utf8)!
        
        // Act: Decode the JSON data into a MovieDetail object
        let decoder = JSONDecoder()
        let movieDetail = try decoder.decode(MovieDetail.self, from: jsonData)
        
        // Assert: Verify that the decoded properties match the expected values
        #expect(movieDetail.id == 550)
        #expect(movieDetail.title == "Fight Club")
        #expect(movieDetail.overview == "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground 'fight clubs' forming in every town, until an eccentric devotee's plan to destroy corporate America threatens to tear them apart.")
        #expect(movieDetail.posterPath == "/pB8BM7pdXLXbZHQPHGygzLDxaNy.jpg")
        #expect(movieDetail.backdropPath == "/8uO0gUM8YaSdeEOEULYLdAB7Pyl.jpg")
        #expect(movieDetail.releaseDate == "1999-10-15")
        #expect(movieDetail.runtime == 139)
        #expect(movieDetail.tagline == "Mischief. Mayhem. Soap.")
        #expect(movieDetail.voteAverage == 8.433)
        #expect(movieDetail.voteCount == 27289)
        #expect(movieDetail.status == "Released")
        
        // Assert: Verify genres
        #expect(movieDetail.genres?.count == 2)
        #expect(movieDetail.genres?[0].id == 18)
        #expect(movieDetail.genres?[0].name == "Drama")
        #expect(movieDetail.genres?[1].id == 53)
        #expect(movieDetail.genres?[1].name == "Thriller")
        
        // Assert: Verify production companies
        #expect(movieDetail.productionCompanies?.count == 2)
        #expect(movieDetail.productionCompanies?[0].id == 508)
        #expect(movieDetail.productionCompanies?[0].name == "Regency Enterprises")
        #expect(movieDetail.productionCompanies?[0].logoPath == "/7PzMZTzU9KzH5yB8zZf0T0.png")
        #expect(movieDetail.productionCompanies?[0].originCountry == "US")
        #expect(movieDetail.productionCompanies?[1].id == 711)
        #expect(movieDetail.productionCompanies?[1].name == "Fox 2000 Pictures")
        #expect(movieDetail.productionCompanies?[1].logoPath == "/tEiFY5PPEr3sM4WjC6X8YgB4ZfW.png")
        #expect(movieDetail.productionCompanies?[1].originCountry == "US")
    }
    
    /// Tests the decoding of MovieDetail when optional properties are missing from the JSON.
    @Test func testMovieDetailDecodingMissingOptionals() throws {
        // Arrange: Sample JSON data for MovieDetail with several optional properties missing
        let jsonString = """
        {
          "id": 999,
          "title": "Movie with Missing Data",
          "overview": null,
          "poster_path": null,
          "backdrop_path": null,
          "release_date": null,
          "runtime": null,
          "tagline": null,
          "vote_average": null,
          "vote_count": null,
          "genres": [],
          "production_companies": [],
          "status": null
        }
        """
        
        // Convert the JSON string to Data
        let jsonData = jsonString.data(using: .utf8)!
        
        // Act: Decode the JSON data into a MovieDetail object
        let decoder = JSONDecoder()
        let movieDetail = try decoder.decode(MovieDetail.self, from: jsonData)
        
        // Assert: Verify that optional properties are nil
        #expect(movieDetail.id == 999)
        #expect(movieDetail.title == "Movie with Missing Data")
        #expect(movieDetail.overview == nil)
        #expect(movieDetail.posterPath == nil)
        #expect(movieDetail.backdropPath == nil)
        #expect(movieDetail.releaseDate == nil)
        #expect(movieDetail.runtime == nil)
        #expect(movieDetail.tagline == nil)
        #expect(movieDetail.voteAverage == nil)
        #expect(movieDetail.voteCount == nil)
        #expect(movieDetail.genres?.isEmpty == true)
        #expect(movieDetail.productionCompanies?.isEmpty == true)
        #expect(movieDetail.status == nil)
    }
    
    /// Tests the explicit public initializer of MovieDetail.
    @Test func testMovieDetailInitialization() {
        // Arrange
        let id = 123
        let title = "Test Title"
        let overview = "Test Overview"
        let posterPath = "/testPoster.jpg"
        let backdropPath = "/testBackdrop.jpg"
        let releaseDate = "2024-01-01"
        let runtime = 120
        let tagline = "Test Tagline"
        let voteAverage = 7.8
        let voteCount = 1234
        let genres = [Genre(id: 1, name: "Action")]
        let productionCompanies = [ProductionCompany(id: 1, name: "Studio A")]
        let status = "Released"
        
        // Act
        let movieDetail = MovieDetail(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            runtime: runtime,
            tagline: tagline,
            voteAverage: voteAverage,
            voteCount: voteCount,
            genres: genres,
            productionCompanies: productionCompanies,
            status: status
        )
        
        // Assert
        #expect(movieDetail.id == id)
        #expect(movieDetail.title == title)
        #expect(movieDetail.overview == overview)
        #expect(movieDetail.posterPath == posterPath)
        #expect(movieDetail.backdropPath == backdropPath)
        #expect(movieDetail.releaseDate == releaseDate)
        #expect(movieDetail.runtime == runtime)
        #expect(movieDetail.tagline == tagline)
        #expect(movieDetail.voteAverage == voteAverage)
        #expect(movieDetail.voteCount == voteCount)
        #expect(movieDetail.genres?.count == 1)
        #expect(movieDetail.genres?[0].name == "Action")
        #expect(movieDetail.productionCompanies?.count == 1)
        #expect(movieDetail.productionCompanies?[0].name == "Studio A")
        #expect(movieDetail.status == status)
    }
    
    /// Tests the computed URL properties of MovieDetail.
    @Test func testMovieDetailURLConstruction() {
        // Arrange
        let posterPath = "/testPosterDetail.jpg"
        let backdropPath = "/testBackdropDetail.jpg"
        
        let movieDetailWithPaths = MovieDetail(
            id: 1,
            title: "Movie with Paths",
            posterPath: posterPath,
            backdropPath: backdropPath
        )
        
        let movieDetailWithoutPaths = MovieDetail(
            id: 2,
            title: "Movie without Paths",
            posterPath: nil,
            backdropPath: nil
        )
        
        // Expected URLs based on your Constants
        let expectedPosterURLString = "\(tmdbKit.Constants.tmdbImageBaseURL)\(tmdbKit.Constants.ImageSize.small.rawValue)\(posterPath)"
        let expectedDetailPosterURLString = "\(tmdbKit.Constants.tmdbImageBaseURL)\(tmdbKit.Constants.ImageSize.medium.rawValue)\(posterPath)"
        let expectedBackdropThumbnailURLString = "\(tmdbKit.Constants.tmdbImageBaseURL)\(tmdbKit.Constants.ImageSize.small.rawValue)\(backdropPath)" // Your model uses .small for backdrop thumbnail
        let expectedBackdropURLString = "\(tmdbKit.Constants.tmdbImageBaseURL)\(tmdbKit.Constants.ImageSize.original.rawValue)\(backdropPath)"
        
        // Act & Assert for movie with paths
        #expect(movieDetailWithPaths.posterURL?.absoluteString == expectedPosterURLString)
        #expect(movieDetailWithPaths.detailPosterURL?.absoluteString == expectedDetailPosterURLString)
        #expect(movieDetailWithPaths.backdropThumbnailURL?.absoluteString == expectedBackdropThumbnailURLString)
        #expect(movieDetailWithPaths.backdropURL?.absoluteString == expectedBackdropURLString)
        
        // Act & Assert for movie without paths
        #expect(movieDetailWithoutPaths.posterURL == nil)
        #expect(movieDetailWithoutPaths.detailPosterURL == nil)
        #expect(movieDetailWithoutPaths.backdropThumbnailURL == nil)
        #expect(movieDetailWithoutPaths.backdropURL == nil)
    }
    
    /// Tests the formatted runtime property of MovieDetail.
    @Test func testMovieDetailFormattedRuntime() {
        // Arrange: MovieDetails with different runtime values
        let movieDetail1 = MovieDetail(id: 1, title: "Long Movie", runtime: 150) // 2h 30m
        let movieDetail2 = MovieDetail(id: 2, title: "Short Movie", runtime: 45)  // 45m
        let movieDetail3 = MovieDetail(id: 3, title: "Exactly One Hour", runtime: 60) // 1h 0m
        let movieDetail4 = MovieDetail(id: 4, title: "No Runtime", runtime: nil) // nil
        
        // Act & Assert
        #expect(movieDetail1.formattedRuntime == "2h 30m")
        #expect(movieDetail2.formattedRuntime == "45m")
        #expect(movieDetail3.formattedRuntime == "1h 0m")
        #expect(movieDetail4.formattedRuntime == nil)
    }
    
    /// Tests the formatted vote average property of MovieDetail.
    @Test func testMovieDetailFormattedVoteAverage() {
        // Arrange: MovieDetails with different vote averages
        let movieDetail1 = MovieDetail(id: 1, title: "High Vote", voteAverage: 8.765)
        let movieDetail2 = MovieDetail(id: 2, title: "Low Vote", voteAverage: 3.1)
        let movieDetail3 = MovieDetail(id: 3, title: "Exact Vote", voteAverage: 7.0)
        let movieDetail4 = MovieDetail(id: 4, title: "No Vote", voteAverage: nil)
        
        // Act & Assert
        #expect(movieDetail1.formattedVoteAverage == "8.8") // Rounded to one decimal place
        #expect(movieDetail2.formattedVoteAverage == "3.1")
        #expect(movieDetail3.formattedVoteAverage == "7.0")
        #expect(movieDetail4.formattedVoteAverage == "N/A")
    }
}

// MARK: - Genre Tests

struct GenreTests {
    
    /// Tests the explicit public initializer of Genre.
    @Test func testGenreInitialization() {
        // Arrange
        let id = 100
        let name = "Action"
        
        // Act
        let genre = Genre(id: id, name: name)
        
        // Assert
        #expect(genre.id == id)
        #expect(genre.name == name)
    }
    
    /// Tests the decoding of a Genre JSON payload.
    @Test func testGenreDecoding() throws {
        // Arrange
        let jsonString = """
            {
              "id": 28,
              "name": "Action"
            }
            """
        let jsonData = jsonString.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let genre = try decoder.decode(Genre.self, from: jsonData)
        
        // Assert
        #expect(genre.id == 28)
        #expect(genre.name == "Action")
    }
}

// MARK: - ProductionCompany Tests

struct ProductionCompanyTests {
    
    /// Tests the explicit public initializer of ProductionCompany with all properties.
    @Test func testProductionCompanyInitializationFull() {
        // Arrange
        let id = 1234
        let name = "Awesome Studios"
        let logoPath = "/path/to/logo.png"
        let originCountry = "US"
        
        // Act
        let company = ProductionCompany(id: id, name: name, logoPath: logoPath, originCountry: originCountry)
        
        // Assert
        #expect(company.id == id)
        #expect(company.name == name)
        #expect(company.logoPath == logoPath)
        #expect(company.originCountry == originCountry)
    }
    
    /// Tests the explicit public initializer of ProductionCompany with optional properties nil.
    @Test func testProductionCompanyInitializationMinimal() {
        // Arrange
        let id = 5678
        let name = "Independent Films"
        
        // Act
        let company = ProductionCompany(id: id, name: name, logoPath: nil, originCountry: nil)
        
        // Assert
        #expect(company.id == id)
        #expect(company.name == name)
        #expect(company.logoPath == nil)
        #expect(company.originCountry == nil)
    }
    
    /// Tests the decoding of a ProductionCompany JSON payload with all properties.
    @Test func testProductionCompanyDecodingFull() throws {
        // Arrange
        let jsonString = """
            {
              "id": 1000,
              "logo_path": "/someLogo.png",
              "name": "Big Production Co.",
              "origin_country": "CA"
            }
            """
        let jsonData = jsonString.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let company = try decoder.decode(ProductionCompany.self, from: jsonData)
        
        // Assert
        #expect(company.id == 1000)
        #expect(company.logoPath == "/someLogo.png")
        #expect(company.name == "Big Production Co.")
        #expect(company.originCountry == "CA")
    }
    
    /// Tests the decoding of a ProductionCompany JSON payload with optional properties missing.
    @Test func testProductionCompanyDecodingMissingOptionals() throws {
        // Arrange
        let jsonString = """
            {
              "id": 2000,
              "name": "Small Indie Studio"
            }
            """
        let jsonData = jsonString.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let company = try decoder.decode(ProductionCompany.self, from: jsonData)
        
        // Assert
        #expect(company.id == 2000)
        #expect(company.name == "Small Indie Studio")
        #expect(company.logoPath == nil) // Should be nil as it's missing in JSON
        #expect(company.originCountry == nil) // Should be nil as it's missing in JSON
    }
}
