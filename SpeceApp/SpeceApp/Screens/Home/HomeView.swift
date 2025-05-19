//
//  HomeView.swift
//  SpeceApp
//
//  Created by Ja on 12/03/2025.
//

import SwiftUI
import SwiftUIReactorKit
import Kingfisher

@MainActor
struct HomeView: ReactorView {
    
    // MARK: - Properties
    
    var reactor: HomeViewViewModel
    
    // MARK: - Body
    
    func body(reactor: HomeViewViewModel.ObservableObject) -> some View {
        content(state: reactor.state)
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    func content(state: HomeViewViewModel.State) -> some View {
        VStack {
            // Title
            Text(String(localized: "home.title"))
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Upcoming Launch or Empty State
            if let launch = reactor.currentState.nextUpcomingLaunch {
                Button(
                    action: { reactor.action.onNext(.openLaunch(launch)) },
                    label: { launchCardView(launch: launch) }
                )
                .buttonStyle(.plain)
            } else {
                EmptyLaunchesView(description: String(localized: "home.upcoming.empty"))
            }
        }
        .padding()
    }
    
    // MARK: - Launch Card View
    
    func launchCardView(launch: LaunchResult) -> some View {
        VStack {
            VStack {
                Spacer()
                LaunchTitleView(name: launch.formattedNameModel.name, mission: launch.formattedNameModel.mission)
                
                LaunchStatusView(launchStatus: launch.status)
                
                if let remainingDate = launch.netDate {
                    let remainingTime = remainingDate.timeIntervalSinceNow
                    CountdownView(remainingTime: remainingTime)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background {
                if let imageUrl = launch.image?.imageBigUrl {
                    KFImage(imageUrl)
                        .placeholder {
                            fallbackImage
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .overlay {
                            LinearGradient(
                                colors: [.clear, .clear, .clear, Color.App.background.opacity(0.4), Color.App.background.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                } else {
                    fallbackImage
                }
            }
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(launch.status.color, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Fallback Image View
    
    @ViewBuilder
    var fallbackImage: some View {
        Image(.blank)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }
}

#Preview {
    HomeView(reactor: HomeViewViewModel())
}
