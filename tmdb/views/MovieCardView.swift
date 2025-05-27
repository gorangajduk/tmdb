//
//  MovieCardView.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import SwiftUI

/// A SwiftUI `View` that displays a single movie card, designed for use within
/// a `UICollectionViewCell` (via `UIHostingController`).
/// It shows the movie's poster, title, and a brief overview.
struct MovieCardView: View {
    /// The `Movie` object containing the data to display.
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading) {
            // Displays the movie poster using AsyncImage.
            // AsyncImage efficiently loads images from URLs and provides placeholders.
            if let url = movie.posterURL {
                AsyncImage(url: url) { image in
                    // When the image successfully loads, display it.
                    image
                        .resizable() // Makes the image resize to fit its frame.
                        .aspectRatio(contentMode: .fit) // Maintains aspect ratio, fitting within bounds.
                        .cornerRadius(8) // Applies rounded corners to the image.
                } placeholder: {
                    // Display a progress indicator while the image is loading.
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures the image fills its available space.
            } else {
                // If no poster URL is available, show a placeholder rectangle.
                Rectangle()
                    .fill(Color.gray.opacity(0.3)) // A light gray background.
                    .cornerRadius(8) // Rounded corners for the placeholder.
                    .overlay(
                        // Overlay text indicating no image is available.
                        Text("No Image")
                            .foregroundColor(.white) // White text for contrast.
                    )
            }

            // Displays the movie's title.
            Text(movie.title)
                .font(.headline) // Uses a prominent font style.
                .lineLimit(2) // Limits the title to two lines to prevent overflow.

            // Displays a short description (overview) of the movie.
            Text(movie.overview)
                .font(.subheadline) // Uses a slightly smaller font.
                .foregroundColor(.gray) // Gray color for secondary information.
                .lineLimit(3) // Limits the description to three lines.
        }
        .padding(8) // Adds internal padding around the content.
        .background(Color.white) // Sets the background color of the card.
        .cornerRadius(10) // Applies rounded corners to the entire card.
        .shadow(radius: 5) // Adds a subtle shadow for depth.
    }
}

---

### Preview Provider

```swift
// Optional: Add a preview for quick design iteration
struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Provides a preview of the MovieCardView with sample movie data.
        // This is invaluable for designing and iterating on the UI without running the full app.
        MovieCardView(movie: Movie(id: 1, title: "Example Movie Title That Is Very Long", overview: "This is a concise overview of an example movie, providing just enough detail to give you an idea of the plot without revealing too much. It should fit nicely within the line limits.", posterPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil))
            .previewLayout(.fixed(width: 150, height: 250)) // Sets a fixed size for the preview.
    }
}
