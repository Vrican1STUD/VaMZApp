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
    
    @Environment(\.dismiss) var dismiss
    
    var reactor: LaunchDetailViewModel
    
    func body(reactor: LaunchDetailViewModel.ObservableObject) -> some View {
        content(state: reactor.state)
    }
    
    @ViewBuilder
    func content(state: LaunchDetailViewModel.State) -> some View {
        VStack {
            switch state.fetchingState {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.Text.primary)
            case .success:
                if let rocketDetail = state.fetchingState.successValue,
                   let notificationDate = rocketDetail.netDate {
                    ScrollView {
                        LaunchImageHeaderView(rocketDetail: rocketDetail, reactor: reactor, notificationDate: notificationDate)
                        
                        VStack (spacing: 16) {
                            CountdownView(remainingTime: state.remainingTime)
                            
                            LaunchStatusView(launchStatus: rocketDetail.status)
                                .padding(.horizontal)
                            
                            SocialMediaView(socialMediaUrls: rocketDetail.socailMediaUrls)
                            
                            TitleText(rocketDetail.rocket.configuration.name)
                            DescriptionText(rocketDetail.rocket.configuration.description)
                            
                            RocketSpecificationView(rocketConfig: rocketDetail.rocket.configuration)
                            
                            TitleText(String(localized: "detail.pad"))
                            DescriptionText(rocketDetail.pad.detailDescription)
                            
                            Button (
                                action: { reactor.action.onNext(.showOnMap(rocketDetail.padLocation)) },
                                label: {
                                    KFImage(URL( string: rocketDetail.pad.mapImage))
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
                        colors: [.clear, .black], startPoint: .top, endPoint: .bottom
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
    
    @ViewBuilder
    func TitleText(_ text: String) -> some View {
        Text(text)
            .font(.title)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.Text.primary)
    }
    
    @ViewBuilder
    func DescriptionText(_ text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.footnote)
            .foregroundStyle(Color.Text.parameters)
    }
}

//#Preview {
//    LaunchDetailView(isSaved: true,
//                     id: "84a2a107-1e44-4994-ad9f-430ee81a741a",
//                     onSave: {})
//}
