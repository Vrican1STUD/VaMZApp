//
//  SocialMediaView.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import SwiftUI
import WebKit

// MARK: - SocialMediaView

/// Displays buttons for social media links (e.g., YouTube video, Wikipedia page)
/// and presents a web view when a link is selected.
struct SocialMediaView: View {
    
    // MARK: Properties
    
    /// Model holding social media URLs
    let socialMediaUrls: SocialLinksModel
    
    /// Currently selected URL for sheet presentation
    @State private var selectedUrl: IdentifiableURL?
    
    // MARK: Body
    
    var body: some View {
        HStack(spacing: 5) {
            // Show YouTube button if a video URL is available
            if let video = socialMediaUrls.vidUrls.first {
                SocialButton(image: .Social.youtube) {
                    selectedUrl = IdentifiableURL(url: video)
                }
            }
            // Show Wikipedia button if a wiki URL is available
            if let wiki = socialMediaUrls.wikiUrl {
                SocialButton(image: .Social.wiki) {
                    selectedUrl = IdentifiableURL(url: wiki)
                }
            }
        }
        // Present a sheet with a WebView when a URL is selected
        .sheet(item: $selectedUrl) { item in
            NavigationView {
                WebView(url: item.url)
                    .navigationBarTitle(String(localized: "social.web"), displayMode: .inline)
                    .navigationBarItems(leading: Button(String(localized: "social.close")) {
                        selectedUrl = nil
                    })
            }
        }
    }
}

// MARK: - IdentifiableURL

/// Wrapper for URL conforming to Identifiable for SwiftUI sheet presentation
struct IdentifiableURL: Identifiable {
    var id: String { url.absoluteString }
    let url: URL
}

// MARK: - WebView

/// UIKit wrapper to embed a WKWebView in SwiftUI
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

// MARK: - Preview

#Preview {
    SocialMediaView(
        socialMediaUrls: SocialLinksModel(
            wikiUrl: "https://en.wikipedia.org/wiki/Falcon_9",
            vidUrls: [VidURL(url: "https://www.youtube.com/watch?v=zyZcFcluStg")]
        )
    )
}
