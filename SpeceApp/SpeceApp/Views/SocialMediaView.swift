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
            if let firstVideo = socialMediaUrls.vidUrls.first {
                Button {
                    selectedUrl = IdentifiableURL(url: firstVideo)
                } label: {
                    Image(.Social.youtube)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.App.Button.normal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            if let wiki = socialMediaUrls.wikiUrl {
                Button {
                    selectedUrl = IdentifiableURL(url: wiki)
                } label: {
                    Image(.Social.wiki)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.App.Button.normal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .sheet(item: $selectedUrl) { item in
            NavigationView {
                WebView(url: item.url)
                    .navigationBarTitle("Web", displayMode: .inline)
                    .navigationBarItems(leading: Button("Close") {
                        selectedUrl = nil
                    })
            }
        }
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
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
