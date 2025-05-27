The MovieDB iOS Client
🚀 Overview
This repository contains an iOS application developed as a technical assignment. The app interacts with The MovieDB API to display trending movies, provide detailed movie information, and enable users to search for various films and series. This project aims to demonstrate advanced Swift programming skills, architectural understanding, and adherence to best practices in iOS development across multiple Apple platforms.

✨ Features
The application implements the following core features:

Main Screen - Trending Movies
Dynamic List Display: Presents a paginated list of trending movies using a UICollectionView with a custom layout.
Infinite Scrolling: Implements infinite scrolling for seamless content loading as the user scrolls.
Concise Movie Entity: Each movie entry clearly displays its title, an image (fetched dynamically based on view size), and a short description.
Details Screen - Movie Information
Comprehensive Details: Tapping on a movie navigates to a dedicated details screen.
Extended Content: This scrollable screen provides rich information beyond standard details, including ratings, vote counts, authors, and other relevant data.
Search Screen - Content Discovery
Search Functionality: Allows users to search for specific movies and series.
Content Type Selection: Users can select whether to search for movies or series in advance.
Throttling: The search input is throttled to optimize API calls and improve performance.
🌟 Bonus Features (If Implemented)
Favorites List: Users can mark movies as favorites, with a local storage mechanism and an indicator on the movie entity itself.
Offline Mode: Provides access to previously viewed content even without an internet connection (using the developer's storage of choice).
Pre-caching: Content is pre-cached via concurrent/queue downloads for immediate access.
Image Optimization: Displays low-resolution images initially, transitioning to high-resolution versions upon full access.
Robust Image Caching: Implements a dedicated image caching mechanism for efficient image loading.
Cross-Platform Core: A core .xcframework containing the model layer, designed for consumption across iOS, iPadOS, tvOS, and macOS.
🛠️ Technical Details & Requirements
This project adheres to the following technical specifications:

Architecture: Utilizes advanced architectural patterns such as MVVM or TCA (The Composable Architecture) to ensure maintainability, testability, and scalability.
UI Frameworks: Demonstrates proficiency in both SwiftUI and UIKit, showcasing knowledge of their respective strengths and integration possibilities.
Dependency Management: SPM (Swift Package Manager) or Cocoapods are used for external dependencies. Network requests are handled using native Swift networking.
Styling: Design, styling, and animations are implemented at the developer's discretion to enhance user experience.
Testing: Includes comprehensive test code coverage (targeting 80%+ for the framework target), including XCTests with expectations, and tests for asynchronous code. UI Tests are also implemented and runnable.
Code Quality: SwiftLint is integrated into Xcode with custom rules to enforce code style and maintain clean code practices.
Adaptability: The interface is fully responsive, supporting both iPad and iOS devices in landscape and portrait modes, with adaptive designs for optimal display across various screen sizes.
Environment Configuration: Supports environment selection (e.g., Prod/Dev) via Xcode schemes and configurations.
Version Control: The assignment is delivered via a Git repository with a clear and meaningful commit history.
Language Consistency: All code, comments, files, and classes maintain English as the primary language.
🎯 Goals & Demonstrations
This assignment serves as a demonstration of:

Advanced Swift Programming: Mastery of advanced Swift concepts, including protocol-oriented programming, object-oriented programming, generics, classes, objects, and access control.
API Integration: Proficiently working with REST APIs and JSON data, including native Swift networking management and handling different request types with queues and concurrency.
Xcode Environments: Expertise in Xcode environments, schemes, shared schemes, and managing environment variables.
Cross-Platform Development: Knowledge and experience in writing code to support cross-platform development (iOS/iPadOS/tvOS/visionOS) and handling API deprecations for older OS versions.
Advanced Interface Builder Concepts: Strategies for proper sourcing and instantiation of .xib and .storyboard files, along with variable Auto Layout traits for universal applications supporting all device classes and orientations.
Clean Code Practices: Adherence to clean code principles, avoiding complexity, cyclomatic dependencies, code duplication, and large function signatures.
XCTest Suite Proficiency: Advanced experience with Xcode's XCTest Suite, including asynchronous testing and UI testing.

🤝 Contributing
This is a technical assignment, so contributions are not expected. However, feel free to explore the codebase.
