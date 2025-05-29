//
//  tmdbUITests.swift
//  tmdbUITests
//
//  Created by Goran Gajduk on 27.5.25.
//

// tmdbUITests.swift

import XCTest
// No need to import tmdbKit or MockURLSession/MockNetworkMonitor here anymore!
// The test target has access to the *types* because the mocks are in the same target.

final class tmdbUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Default launch argument for online scenario, or you can have a specific one
        app.launchArguments = ["-uiTestMode"] // Start with a clean set of arguments
        // app.launchArguments.append("-uiTestMode:online") // More explicit if you prefer
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate() // Terminate app after each test to ensure clean state
        app = nil // Clear app instance
    }

    /// Test to ensure the main Trending Movies screen loads and displays its collection view.
    func testTrendingMoviesScreenLoads() throws {
        // App is launched with default mock setup from setUpWithError()
        let trendingMoviesCollectionView = app.collectionViews["trendingMoviesCollectionView"]
        XCTAssertTrue(trendingMoviesCollectionView.waitForExistence(timeout: 5), "The trending movies collection view should exist on screen.")

        let navigationBar = app.navigationBars["Trending Movies"]
        XCTAssertTrue(navigationBar.exists, "The navigation bar with title 'Trending Movies' should exist.")

        let searchButton = navigationBar.buttons["searchButton"]
        XCTAssertTrue(searchButton.exists, "The search button should be present in the navigation bar.")

        let firstMockMovieCell = trendingMoviesCollectionView.cells["movieCell_0"]
        XCTAssertTrue(firstMockMovieCell.waitForExistence(timeout: 5), "The first mock movie cell should exist.")
        // You can add more specific assertions here, e.g., check text of a label
        // XCTAssertTrue(firstMockMovieCell.staticTexts["Mock Movie 1"].exists)
    }

    /// Test to simulate offline mode and verify the error alert appears.
    func testOfflineModeDisplaysErrorAlert() throws {
        app.terminate() // Terminate the app launched in setUpWithError
        app = XCUIApplication() // Re-initialize XCUIApplication

        // Pass the specific launch argument for the offline scenario
        app.launchArguments = ["-uiTestMode", "-uiTestMode:offline"]
        app.launch() // Launch with the new mock setup

        let errorAlert = app.alerts["errorAlert"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 10), "The error alert should appear when offline.")

        let alertTitle = errorAlert.staticTexts["Error"]
        let alertMessage = errorAlert.staticTexts["You are currently offline and no cached data is available for this content."]
        XCTAssertTrue(alertTitle.exists, "Error alert should have title 'Error'.")
        XCTAssertTrue(alertMessage.exists, "Error alert should have the correct offline message.")

        let okButton = errorAlert.buttons["okButton"]
        XCTAssertTrue(okButton.exists, "The 'OK' button should exist on the error alert.")
        okButton.tap()

        XCTAssertFalse(errorAlert.exists, "The error alert should disappear after tapping OK.")
    }

    /// Example test to verify tapping a movie cell leads to the detail screen.
    func testMovieCellTapNavigatesToDetail() throws {
        app.terminate() // Terminate the app launched in setUpWithError
        app = XCUIApplication() // Re-initialize XCUIApplication

        // Pass the specific launch argument for the movie detail scenario
        app.launchArguments = ["-uiTestMode", "-uiTestMode:movieDetailMock"]
        app.launch() // Launch with the new mock setup

        let collectionView = app.collectionViews["trendingMoviesCollectionView"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "Collection view should exist.")

        let firstMovieCell = collectionView.cells["movieCell_0"]
        XCTAssertTrue(firstMovieCell.waitForExistence(timeout: 5), "The first movie cell should exist.")

        firstMovieCell.tap()

        let movieDetailView = app.otherElements["movieDetailView"]
        XCTAssertTrue(movieDetailView.waitForExistence(timeout: 5), "Movie detail view should appear after tapping a cell.")

        let backButton = app.navigationBars.buttons.element(boundBy: 0) // Assuming the first button is the back button
        if backButton.exists {
            backButton.tap()
            XCTAssertTrue(collectionView.waitForExistence(timeout: 2), "Should return to trending movies collection view.")
        } else {
            print("Warning: Back button not found for navigation test.")
        }
    }
}
