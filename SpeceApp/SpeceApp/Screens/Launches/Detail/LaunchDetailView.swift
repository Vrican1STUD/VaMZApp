//
//  LaunchDetailView.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI
import SwiftUIReactorKit
import Kingfisher

@MainActor
struct LaunchDetailView: ReactorView {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Properties
    
    var reactor: LaunchDetailViewModel
    
    // MARK: - Body
    
    func body(reactor: LaunchDetailViewModel.ObservableObject) -> some View {
        content(state: reactor.state)
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    func content(state: LaunchDetailViewModel.State) -> some View {
        VStack {
            switch state.fetchingState {
            case .idle:
                // No content yet
                EmptyView()
                
            case .loading:
                // Show loading spinner with large size and tinted color
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.Text.primary)
                
            case .success:
                // Display launch details if available
                if let rocketDetail = state.fetchingState.successValue,
                   let notificationDate = rocketDetail.netDate {
                    ScrollView {
                        // Header with image and notification bell
                        LaunchImageHeaderView(rocketDetail: rocketDetail, reactor: reactor, notificationDate: notificationDate)
                        
                        VStack(spacing: 16) {
                            // Countdown timer for launch
                            CountdownView(remainingTime: state.remainingTime)
                            
                            // Status indicator for launch
                            LaunchStatusView(launchStatus: rocketDetail.status)
                                .padding(.horizontal)
                            
                            // Social media links
                            SocialMediaView(socialMediaUrls: rocketDetail.socailMediaUrls)
                            
                            // Rocket name and description
                            TitleText(rocketDetail.rocket.configuration.name)
                            DescriptionText(rocketDetail.rocket.configuration.description)
                            
                            // Rocket specifications view
                            RocketSpecificationView(rocketConfig: rocketDetail.rocket.configuration)
                            
                            // Launch pad details
                            TitleText(String(localized: "detail.pad"))
                            DescriptionText(rocketDetail.pad.detailDescription)
                            
                            // Map image button, tapping shows location on map
                            Button(
                                action: { reactor.action.onNext(.showOnMap(rocketDetail.padLocation)) },
                                label: {
                                    KFImage(URL(string: rocketDetail.pad.mapImage))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxHeight: 200)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                })
                        }
                        .padding(16)
                    }
                    .onAppear { reactor.action.onNext(.updateCountdownNow) }
                }
                
            case .error(let error):
                // Show error view with retry option
                LaunchErrorView(error: error, onRetry: { reactor.action.onNext(.refreshLaunchDetail) })
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            CloseButtonView(action: { dismiss() })
        }
    }
    
    // MARK: - Subviews
    
    /// Header view with large image, title, and notification bell
    @ViewBuilder
    func LaunchImageHeaderView(rocketDetail: LaunchDetailResult, reactor: LaunchDetailViewModel, notificationDate: Date) -> some View {
        VStack {
            KFImage(rocketDetail.image.imageBigUrl)
                .resizable()
                .scaledToFill()
                .frame(minHeight: 300)
                .ignoresSafeArea(edges: .top)
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [.clear, Color.App.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .overlay(alignment: .bottom) {
                    HStack {
                        LaunchTitleView(
                            name: rocketDetail.formattedNameModel.name,
                            mission: rocketDetail.formattedNameModel.mission
                        )
                        Spacer()
                        NotificationBellView(
                            bellSize: 30.0,
                            canManipulate: reactor.canManipulateNotification(netDate: notificationDate),
                            isSaved: reactor.currentState.isSaved,
                            netDate: notificationDate,
                            onTap: {
                                // Toggle saved launch state and notifications
                                reactor.action.onNext(.toggleSavedLaunch)
                                NotificationManager.shared.toggleLaunchNotification(launch: reactor.currentState.launch)
                            }
                        )
                        .padding(.leading)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                }
        }
    }
    
    /// Close button at top-left corner to dismiss the view
    @ViewBuilder
    func CloseButtonView(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundStyle(.white)
                .background(Color.App.Button.normal)
                .clipShape(Circle())
        }
        .padding(16)
    }
    
    /// Styled title text
    @ViewBuilder
    func TitleText(_ text: String) -> some View {
        Text(text)
            .font(.title)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.Text.primary)
    }
    
    /// Styled description text
    @ViewBuilder
    func DescriptionText(_ text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.footnote)
            .foregroundStyle(Color.Text.parameters)
    }
}
