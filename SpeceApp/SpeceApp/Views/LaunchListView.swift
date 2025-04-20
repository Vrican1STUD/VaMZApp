//
//  LaunchListView.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI
import Kingfisher

@MainActor
struct LaunchListView: View {
    
    let launch: LaunchResult
    let isSaved: Bool
    let onTap: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        Button(
            action: { onTap() },
            label: { label }
        )
        .buttonStyle(.plain)
    }
    
    var label: some View {
        HStack(alignment: .center) {
            if let imageUrl = launch.image?.imageUrl {
                KFImage(imageUrl)
                    .placeholder({ ProgressView() })
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70)
                    .clipped()
            } 
            else {
                Image(.astronaut)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70)
            }
            VStack {
                VStack(alignment: .leading) {
                    Text(launch.name)
                        .foregroundStyle(Color.Text.primary)
                        .bold()
                    if let net = launch.netString {
                        Text(net)
                            .foregroundStyle(Color.Text.parameters)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            
            VStack {
                Image(systemName: isSaved ? "bell.fill" : "bell")
                    .resizable()
                    .transition(.scale.combined(with: .opacity))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.red)
                    .padding(20)
//                    .id(isSaved)
            }
            .animation(.bouncy, value: isSaved)
            .onTapGesture { onSave() }
        }
        .background(Color.App.SegmentControl.normal)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(maxHeight: 150)
    }
    
    
}

#Preview {
    LaunchListView(
        launch: LaunchResult(id: "", url: "", name: "FalconSat", slug: "", lastUpdated: "", net: "2025-04-03T22:54:00Z", windowEnd: "", windowStart: "", image: LaunchImage(thumbnailUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png"), failreason: "", webcastLive: true, orbitalLaunchAttemptCount: 2), 
        isSaved: false,
        onTap: { print("Ahoj") },
        onSave: {}
    )
}

struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.default, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaledButtonStyle {
    static var scaled: Self { ScaledButtonStyle() }
}

extension Date {
    
    static let dateFormatter = DateFormatter()
    
    
    func string(format: DateFormat) -> String {
        Self.dateFormatter.dateFormat = format.rawValue
        
        return Self.dateFormatter.string(from: self)
    }
    

}

enum DateFormat: String {
    case ddMMYYYY = "dd.MM.YYYY"
}
