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
            label: { listView }
        )
        .buttonStyle(.plain)
    }
    
    var listView: some View {
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
                        .fontWeight(.bold)
                        .foregroundStyle(Color.Text.primary)
                    
                    Text(launch.formattedNameModel.mission)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.Text.info)
                    HStack {
                        if let net = launch.netString {
                            Text(net)
                                .foregroundStyle(Color.Text.parameters)
                        }
                        Text(launch.status.abbrev)
                            .foregroundStyle(launch.status.color)
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            
            VStack {
                if let notificationDate = launch.netDate {
                    NotificationBellView(
                        bellSize: 20.0,
                        canManipulate: NotificationManager.shared.canManipulateNotification(date: notificationDate),
                        isSaved: isSaved,
                        netDate: notificationDate,
                        onTap: { onSave() }
                    )
                    .padding(20)
                }
            }
            .animation(.bouncy, value: isSaved)
            .onTapGesture { onSave() }
        }
        .background(Color.App.SegmentControl.normal)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(launch.status.color, lineWidth: 1)
        )
        .frame(maxHeight: 150)
    }
}

//#Preview {
//    LaunchListView(
//        launch: LaunchResult(id: "", url: "", name: "FalconSat", slug: "", status: LaunchStatus(rawValue: 0), lastUpdated: "", net: "2025-04-03T22:54:00Z", windowEnd: "", windowStart: "", image: LaunchImage(imageUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png",
//            thumbnailUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png")),
//        isSaved: false,
//        onTap: { print("Ahoj") },
//        onSave: {}
//    )
//}
