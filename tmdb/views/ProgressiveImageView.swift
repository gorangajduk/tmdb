//
//  ProgressiveImageView.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import SwiftUI

/// A reusable SwiftUI view for progressive image loading.
/// It displays a low-resolution image as a placeholder while the high-resolution image loads,
/// then transitions smoothly to the final image. Includes loading indicators and error fallbacks.
struct ProgressiveImageView: View {
    /// The URL for the low-resolution image (e.g., thumbnail).
    let lowResURL: URL?
    /// The URL for the high-resolution (final) image.
    let highResURL: URL?
    /// The content mode for the image (e.g., .fit, .fill).
    let contentMode: ContentMode
    /// Optional blur radius applied to the low-resolution image.
    let lowResBlurRadius: CGFloat
    /// Optional text to display if no image URLs are provided or loading fails.
    let noImageText: String?
    /// Optional icon to display if no image URLs are provided or loading fails.
    let noImageIcon: String? // Changed to String? for SF Symbol name

    /// Initializes the progressive image view.
    /// - Parameters:
    ///   - lowResURL: The URL for the initial low-resolution image.
    ///   - highResURL: The URL for the final high-resolution image.
    ///   - contentMode: How the image should scale to fit its container. Defaults to `.fit`.
    ///   - lowResBlurRadius: The blur to apply to the low-res image. Defaults to `2.0`.
    ///   - noImageIcon: System icon name (e.g., "photo.fill") for no image placeholder. Defaults to `nil` (uses text).
    init(lowResURL: URL?, highResURL: URL?, contentMode: ContentMode = .fit, lowResBlurRadius: CGFloat = 2.0, noImageText: String? = nil, noImageIcon: String? = nil) {
        self.lowResURL = lowResURL
        self.highResURL = highResURL
        self.contentMode = contentMode
        self.lowResBlurRadius = lowResBlurRadius
        self.noImageText = noImageText
        self.noImageIcon = noImageIcon
    }
    
    var body: some View {
        AsyncImage(url: highResURL) { phase in
            switch phase {
            case .success(let image):
                // If the high-res image is successfully loaded, display it.
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .empty, .failure:
                // In case of loading (.empty) or failure (.failure) for the high-res image,
                // attempt to show the low-res image as a fallback/placeholder.
                AsyncImage(url: lowResURL) { lowResPhase in
                    switch lowResPhase {
                    case .success(let lowResImage):
                        // If low-res loads, show it with blur.
                        lowResImage
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                            .blur(radius: lowResBlurRadius)
                            .transition(.opacity) // Smooth transition if low-res loads fast
                    case .failure:
                        // If low-res also fails, show a general error/no image placeholder.
                        defaultPlaceholder(text: "Failed to Load", icon: noImageIcon)
                    case .empty:
                        // Show a loading indicator while low-res image is loading.
                        // This acts as the initial placeholder before any image is available.
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the image fills its container
    }

    /// Provides a default placeholder view with optional text and SF Symbol icon.
    @ViewBuilder
    private func defaultPlaceholder(text: String?, icon: String?) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                VStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.bottom, 4)
                    }
                    if let text = text {
                        Text(text)
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }
            )
    }
}

// MARK: - Preview Provider
struct ProgressiveImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with both URLs
            ProgressiveImageView(
                lowResURL: URL(string: "https://image.tmdb.org/t/p/w92/7GqBpiwU9mX2bM40vEwD2Y1oY8A.jpg"),
                highResURL: URL(string: "https://image.tmdb.org/t/p/w500/7GqBpiwU9mX2bM40vEwD2Y1oY8A.jpg"),
                contentMode: .fit
            )
            .frame(width: 150, height: 225)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.blue.opacity(0.1))
            .previewDisplayName("Both URLs")

            // Preview with only high-res (low-res will be default placeholder initially)
            ProgressiveImageView(
                lowResURL: nil,
                highResURL: URL(string: "https://image.tmdb.org/t/p/w500/rMtmW9n9LwK72099T99X8eNf1C2.jpg"),
                contentMode: .fill
            )
            .frame(width: 200, height: 300)
            .clipped()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.red.opacity(0.1))
            .previewDisplayName("High-Res Only")

            // Preview with no URLs
            ProgressiveImageView(
                lowResURL: nil,
                highResURL: nil,
                contentMode: .fit,
                noImageIcon: "nosign"
            )
            .frame(width: 150, height: 225)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.green.opacity(0.1))
            .previewDisplayName("No URLs")
        }
    }
}
