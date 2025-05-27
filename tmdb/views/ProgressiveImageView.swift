//
//  ProgressiveImageView.swift
//  tmdb
//
//  Created by Goran Gajduk on 27.5.25.
//

import SwiftUI
import Kingfisher

/// A reusable SwiftUI view for progressive image loading.
/// It displays a low-resolution image as a placeholder while the high-resolution image loads,
/// then transitions smoothly to the final image. Includes loading indicators and error fallbacks.
struct ProgressiveImageView: View {
    /// The URL for the low-resolution image (e.g., thumbnail).
    let lowResURL: URL?
    /// The URL for the high-resolution (final) image.
    let highResURL: URL?
    /// The content mode for the image (e.g., .fit, .fill).
    let contentMode: SwiftUI.ContentMode
    /// Optional blur radius applied to the low-resolution image.
    let lowResBlurRadius: CGFloat
    /// Optional text to display if no image URLs are provided or loading fails.
    let noImageText: String?
    /// Optional icon to display if no image URLs are provided or loading fails.
    let noImageIcon: String? // Changed to String? for SF Symbol name
    
    @State private var highResLoaded = false
    @State private var lowResLoaded = false
    @State private var loadingFailed = false

    /// Initializes the progressive image view.
    /// - Parameters:
    ///   - lowResURL: The URL for the initial low-resolution image.
    ///   - highResURL: The URL for the final high-resolution image.
    ///   - contentMode: How the image should scale to fit its container. Defaults to `.fit`.
    ///   - lowResBlurRadius: The blur to apply to the low-res image. Defaults to `2.0`.
    ///   - noImageIcon: System icon name (e.g., "photo.fill") for no image placeholder. Defaults to `nil` (uses text).
    init(lowResURL: URL?,
         highResURL: URL?,
         contentMode: SwiftUI.ContentMode = .fit,
         lowResBlurRadius: CGFloat = 2.0,
         noImageText: String? = nil,
         noImageIcon: String? = nil) {
        self.lowResURL = lowResURL
        self.highResURL = highResURL
        self.contentMode = contentMode
        self.lowResBlurRadius = lowResBlurRadius
        self.noImageText = noImageText
        self.noImageIcon = noImageIcon
    }
    
    var body: some View {
        ZStack {
            // Low-res image layer (loads first)
            if !highResLoaded {
                KFImage(lowResURL)
                    .onSuccess { result in
                        lowResLoaded = true
                    }
                    .onFailure { error in
                        if !highResLoaded {
                            loadingFailed = true
                        }
                    }
                    .placeholder {
                        ProgressView()
                    }
                    .retry(maxCount: 2)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .blur(radius: lowResBlurRadius)
                    .opacity(lowResLoaded && !highResLoaded ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: lowResLoaded)
            }
            
            // High-res image layer (loads after low-res)
            KFImage(highResURL)
                .onSuccess { result in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        highResLoaded = true
                    }
                }
                .onFailure { error in
                    // If high-res fails but we have low-res, keep showing low-res
                    if !lowResLoaded {
                        loadingFailed = true
                    }
                }
                .retry(maxCount: 3)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .opacity(highResLoaded ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: highResLoaded)
            
            // Error/fallback state
            if loadingFailed && !lowResLoaded && !highResLoaded {
                defaultPlaceholder(text: noImageText ?? "Failed to Load", icon: noImageIcon)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
