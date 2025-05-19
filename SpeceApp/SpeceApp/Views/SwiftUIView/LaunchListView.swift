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
    
    // MARK: - Properties
    
    /// The launch data to display
    let launch: LaunchResult
    
    /// Indicates whether this launch is saved/bookmarked
    let isSaved: Bool
    
    /// Closure to call when the launch row is tapped
    let onTap: () -> Void
    
    /// Closure to call when the save toggle is tapped
    let onSave: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: { onTap() },
            label: { listView }
        )
        .buttonStyle(.plain)
    }
    
    // MARK: - View Components
    
    /// Main list row view showing launch details and notification bell
    var listView: some View {
        HStack(alignment: .center) {
            // Launch image thumbnail or default astronaut icon
            if let imageUrl = launch.image?.imageThumbnailUrl {
                KFImage(imageUrl)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70)
                    .clipped()
            } else {
                Image(.astronaut)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70)
            }
            
            // Launch information: name, mission, date, status
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
            
            // Notification bell view for saved launch notifications
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
            .animation(.bouncy, value: isSaved) // Animate save toggle
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
