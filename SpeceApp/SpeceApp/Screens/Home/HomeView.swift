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
        
    var reactor: HomeViewViewModel
    
    func body(reactor: HomeViewViewModel.ObservableObject) -> some SwiftUI.View {
        content(state: reactor.state)
    }
    
    @ViewBuilder
    func content(state: HomeViewViewModel.State) -> some SwiftUI.View {
        VStack {
            Text("Upcoming")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let launch = reactor.currentState.nextUpcomingLaunch {
                Button(
                    action: { reactor.action.onNext(.openLaunch(launch)) },
                    label: { label }
                )
                .buttonStyle(.plain)
            } else {
                emptyView
            }
        }
        .padding()
    }
    
    
    var label: some View {
        VStack {
            if let launch = reactor.currentState.nextUpcomingLaunch {
                VStack {
                    Spacer()
                    Group {
                        Text(launch.formattedNameModel.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(launch.formattedNameModel.mission)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    
                    if let remainingDate = launch.netDate {
                        let remainingTime = remainingDate.timeIntervalSinceNow
                        CountdownView(remainingTime: remainingTime)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background{
                    VStack {
                        if let imageUrl = launch.image?.imageBigUrl {
                            KFImage(imageUrl)
                                .placeholder {
                                    Image(.blank)
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .clipped()
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                .overlay{
                                    LinearGradient(
                                        colors: [.clear, .clear, .clear, .black.opacity(0.4), .black.opacity(0.8)], startPoint: .top, endPoint: .bottom
                                    )
                                }
                        } else {
                            Image(.blank)
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        }
                    }
                }
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.App.SegmentControl.normal, lineWidth: 1)
                )
            }
        }
    }
    
    @ViewBuilder
    var emptyView: some SwiftUI.View {
        VStack {
            Spacer()
            Image(.astronaut)
            Text("No saved upcoming Launches")
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    HomeView(reactor: HomeViewViewModel())
}
