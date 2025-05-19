//
//  SocialMediaView.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import SwiftUI

struct SocialMediaView: View {
    
    let socialMediaUrls: SocialLinksModel
    @State private var selectedUrl: IdentifiableURL?
    
    var body: some View {
        HStack(spacing: 5) {
            if let video = socialMediaUrls.vidUrls.first {
                SocialButton(image: .Social.youtube) {
                    selectedUrl = IdentifiableURL(url: video)
                }
            }
            if let wiki = socialMediaUrls.wikiUrl {
                SocialButton(image: .Social.wiki) {
                    selectedUrl = IdentifiableURL(url: wiki)
                }
            }
        }
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

struct IdentifiableURL: Identifiable {
    var id: String { url.absoluteString }
    let url: URL
}

import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

#Preview {
    SocialMediaView(socialMediaUrls: SocialLinksModel(wikiUrl: "https://en.wikipedia.org/wiki/Falcon_9", vidUrls: [VidURL(url: "https://www.youtube.com/watch?v=zyZcFcluStg")]))
}
