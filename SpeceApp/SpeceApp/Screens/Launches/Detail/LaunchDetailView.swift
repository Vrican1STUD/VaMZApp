//
//  LaunchDetailView.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI
import Kingfisher

//TODO: Gesture doesn't work
struct LaunchDetailView: View {
    @ObservedObject var viewModel = LaunchDetailViewModel()
    
    @State var isSaved: Bool
    let id: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            switch viewModel.fetchingState {
            case .idle:
                EmptyView()
                Text("empty")
                
            case .loading:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.Text.primary)
                
            case .success:
                if let rocketDetail = viewModel.fetchingState.successValue {
                    ScrollView {
                        VStack {
                            KFImage(rocketDetail.image.imageUrl)
                            //                .placeholder({ ProgressView() })
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .ignoresSafeArea(edges: .top)
                                .clipped()
                                .overlay(alignment: .bottom) {
                                    LinearGradient(
                                        colors: [.clear, .black], startPoint: .top, endPoint: .bottom
                                    )
                                }
                                .overlay(alignment: .bottom) {
                                HStack {
                                    Text(rocketDetail.name)
                                        .font(.title)
                                        .bold()
                                    VStack {
                                        Image(systemName: isSaved ? "bell.fill" : "bell")
                                            .resizable()
                                            .scaledToFit()
                                            .transition(.scale.combined(with: .opacity))
                                            .frame(width: 30)
                                            .foregroundStyle(.red)
                                            .padding(.leading)
                                    }
                                    .animation(.bouncy, value: isSaved)
                                    .onTapGesture { 
                                        onSave()
                                        isSaved = !isSaved
                                    }
                                }
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        VStack (spacing: 16) {
                            Text(viewModel.countdownText)
                            //                            CountdownView(days: viewModel.days, hours: viewModel.hours, minutes: viewModel.minutes)
                            SocialMediaView()
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
                            Button (action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
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
                }
            case .error(let error):
                //                errorView(error: error)
                Text("error")
            }
            
        }
        .scrollIndicators(.hidden)
        //        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
                viewModel.fetchingState = .idle
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
        .onAppear {
            viewModel.fetchData(id: id)
        }
        .onDisappear {
            viewModel.deleteTasks()
        }
//        .task {
//            guard !viewModel.fetchingState.isSuccess else { return }
////            viewModel.fetchingState = .idle
//            await viewModel.fetchDetail(isPullToRefresh: false, id: id)
//        }
    }
    
}

#Preview {
    LaunchDetailView(isSaved: true,
                     id: "84a2a107-1e44-4994-ad9f-430ee81a741a",
                     onSave: {})
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
