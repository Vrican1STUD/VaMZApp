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
            if let imageUrl = launch.image?.imageThumbnailUrl {
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

                    Text(launch.formattedNameModel.name)
//                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.Text.primary)
                    
                    Text(launch.formattedNameModel.mission)
//                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.Text.info)
                    
                    if let net = launch.netString {
                        Text(net)
                            .foregroundStyle(Color.Text.parameters)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            
            VStack {
                if let notificationDate = launch.netDate {
                    let bellColor = NotificationManager.shared.canManipulateNotification(date: notificationDate) ? Color.red : Color.white
                    Image(systemName: isSaved ? "bell.fill" : "bell")
                        .resizable()
                        .transition(.scale.combined(with: .opacity))
                        .frame(width: 20, height: 20)
                        .foregroundStyle(bellColor)
                        .padding(20)
                        .id(isSaved)
                }
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
        launch: LaunchResult(id: "", url: "", name: "FalconSat", slug: "", lastUpdated: "", net: "2025-04-03T22:54:00Z", windowEnd: "", windowStart: "", image: LaunchImage(imageUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png",
            thumbnailUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png")),
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
