//
//  MovieCardView.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

// Example Views/SwiftUI/MovieCardSwiftUIView.swift
import SwiftUI

struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading) {
            if let url = movie.posterURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        Text("No Image")
                            .foregroundColor(.white)
                    )
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

// Optional: Add a preview for quick design iteration
struct MovieCardSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCardView(movie: Movie(id: 1, title: "Example Movie", overview: "A very long description of an example movie that goes on and on.", posterPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil))
            .previewLayout(.fixed(width: 150, height: 250))
    }
}
