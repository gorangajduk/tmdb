//
//  MovieCardView.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import SwiftUI
import tmdbKit

struct MovieCardView: View {
    let movie: Movie
    @ObservedObject private var favoritesManager = FavoriteMoviesManager.shared

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                ProgressiveImageView(
                    lowResURL: movie.thumbnailPosterURL, // Your w92 image
                    highResURL: movie.posterURL,       // Your w200 image
                    contentMode: .fit,
                    lowResBlurRadius: 2.0,
                    noImageText: "No Poster"
                )
                .cornerRadius(8)
                   
                
                Image(systemName: favoritesManager.isFavorite(movieID: movie.id) ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundColor(favoritesManager.isFavorite(movieID: movie.id) ? .yellow : .gray)
                    .shadow(radius: 2)
                    .padding(6)
            }
            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
            Text(movie.overview)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3) // Short description
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}


struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Provides a preview of the MovieCardView with sample movie data.
        // This is invaluable for designing and iterating on the UI without running the full app.
        MovieCardView(
            movie: Movie(
                id: 1,
                title: "Example Movie Title That Is Very Long",
                overview: "This is a concise overview of an example movie, providing just enough detail to give you an idea of the plot without revealing too much. It should fit nicely within the line limits.",
                posterPath: nil,
                releaseDate: nil,
                voteAverage: nil,
                voteCount: nil
            )
        )
            .previewLayout(.fixed(width: 150, height: 250)) // Sets a fixed size for the preview.
    }
}
