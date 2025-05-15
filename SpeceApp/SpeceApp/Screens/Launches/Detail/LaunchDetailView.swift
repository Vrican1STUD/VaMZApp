//
//  LaunchDetailView.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUIReactorKit
import Kingfisher

@MainActor
struct LaunchDetailView: ReactorView {
    
    @Environment(\.dismiss) var dismiss
    
    var reactor: LaunchDetailViewModel
    
    func body(reactor: LaunchDetailViewModel.ObservableObject) -> some SwiftUI.View {
        content(state: reactor.state)
    }
    
    @ViewBuilder
    func content(state: LaunchDetailViewModel.State) -> some SwiftUI.View {
        VStack {
            switch state.fetchingState {
            case .idle:
                EmptyView()
                //                Text("empty")
                //                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loading:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.Text.primary)
            case .success:
                if let rocketDetail = state.fetchingState.successValue {
                    ScrollView {
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
                                    HStack() {
                                        VStack(alignment: .leading) {
                                            Text(rocketDetail.formattedNameModel.name)
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundStyle(Color.Text.primary)
                                            Text(rocketDetail.formattedNameModel.mission)
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundStyle(Color.Text.info)
                                        }
                                        Spacer()
                                        VStack {
                                            Image(systemName: reactor.currentState.isSaved ? "bell.fill" : "bell")
                                                .resizable()
                                                .scaledToFit()
                                                .transition(.scale.combined(with: .opacity))
                                                .frame(width: 30)
                                                .foregroundStyle(.red)
                                                .padding(.leading)
                                                .id(reactor.currentState.isSaved)
                                        }
                                        .animation(.bouncy, value: reactor.currentState.isSaved )
                                        .onTapGesture { reactor.action.onNext(.toggleSavedLaunch) }
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                }
                        }
                        
                        VStack (spacing: 16) {
                            CountdownView(remainingTime: state.remainingTime)
                            SocialMediaView(socialMediaUrls: rocketDetail.socailMediaUrls)
                            Text(rocketDetail.rocket.configuration.name)
                                .font(.title)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: . leading)
                                .foregroundStyle(Color.Text.primary)
                            Text(rocketDetail.rocket.configuration.description)
                                .frame(maxWidth: .infinity, alignment: . leading)
                                .font(.footnote)
                                .foregroundStyle(Color.Text.parameters)
                            
                            RocketSpecificationView(rocketConfig: rocketDetail.rocket.configuration)
                            
                            Text("Launchpad")
                                .font(.title)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: . leading)
                            let padDescription = rocketDetail.pad.description ?? rocketDetail.pad.name
                            Text(padDescription.isEmpty ? rocketDetail.pad.name : padDescription)
                                .frame(maxWidth: .infinity, alignment: . leading)
                                .font(.footnote)
                                .foregroundStyle(Color.Text.parameters)
                            Button (
                                action: { },
                                label: {
                                    KFImage(URL( string: rocketDetail.pad.mapImage))
                                    //                .placeholder({ ProgressView() })
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxHeight: 200)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                })
                        }
                        .padding(16)
                    }
                    .onAppear {
                        reactor.action.onNext(.updateCountdownNow)
                    }
                }
            case .error(let error):
                errorView(error: error)
            }
        }
        .scrollIndicators(.hidden)
        //        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundStyle(.white)
                        .background(Color.App.Button.normal)
                        .clipShape(Circle())
                }
            }
            .padding(16)
        }
    }
    
    func errorView(error: AppError) -> some SwiftUI.View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(.astronaut)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(.bottom, 32)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
            
            Button {
                reactor.action.onNext(.refreshLaunchDetail)
            } label: {
                Text("Retry")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 60)
                    .background(Color.App.Button.normal)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.scaled)
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding()
    }
}

//#Preview {
//    LaunchDetailView(isSaved: true,
//                     id: "84a2a107-1e44-4994-ad9f-430ee81a741a",
//                     onSave: {})
//}

//extension UINavigationController: UIGestureRecognizerDelegate {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        interactivePopGestureRecognizer?.delegate = self
//    }
//
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return viewControllers.count > 1
//    }
//}
