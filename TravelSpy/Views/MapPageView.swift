//
//  MapPageView.swift
//  TravelSpy
//
//  Created by AlexK on 12/01/2022.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import WaterfallGrid


struct MapPageView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var viewAlertModel: AlertViewModel
    @EnvironmentObject var userPostsModel: UserPostsModel
    
    @StateObject var postsModel = PostsModel()
    
    @State private var showDetailedView = false
    @State private var detailedForPost: Post?
    
    let location: Location
    
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack {
                MapView(location: location)
                    .frame(height: 200)
                
                LazyVStack {
                    WaterfallGrid(postsModel.posts) { post in
                        VStack {
                            if !post.uid.isEmpty {
                                if post.imageUrl != nil {
                                    ImageLoadingView(url: post.imageUrl!)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 80)
                                        .clipped()
                                }
                            }
                        }
                        .cornerRadius(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.5))
                        )
                        .onTapGesture {
                            openDetailedView(post: post)
                        }
                        .sheet(item: $detailedForPost) { item in
                            DetailsView(post: item)
                        }
                    }
                    .gridStyle(
                        columns: 4,
                        spacing: 5,
                        animation: .easeInOut(duration: 0.5)
                    )
                    .padding(EdgeInsets(top: 16, leading: 5, bottom: 70, trailing: 1))
                    
                    if postsModel.posts.count < postsModel.totalCount {
                        ProgressView()
                            .frame(height: 40)
                            .onAppear {
                                //                                fetchPreviousPosts()
                            }
                    }
                }
            }
        }
        .onAppear {
            fetchPosts()
        }
        .navigationTitle(location.countryAndCity)
        .navigationBarItems(trailing: Button(action: {
            followLocation()
        }) {
            Image(systemName: isFollowLocation() ? "mappin.circle" : "mappin.slash.circle")
        })
    }

    private func isFollowLocation() -> Bool {
        return sessionStore.profile!.locationsFollowing.contains(location.key)
    }

    private func followLocation() {
        Task {
            let action: SessionStore.LocationAction = isFollowLocation() ? .unfollow : .follow
            await sessionStore.followLocation(location, action: action)
            userPostsModel.removeAll()

            let actionMessage = isFollowLocation() ? "follow" : "unfollow"
            self.viewAlertModel.setAlert(status: .success, title: "You have \(actionMessage) the location.")
        }
    }
    
    private func openDetailedView(post: Post) {
        detailedForPost = post
        showDetailedView = true
    }
    
    private func fetchPosts() {
        Task {
            await postsModel.fetchPostsFor(location: location)
        }
    }
}

struct MapPageView_Previews: PreviewProvider {
    static var previews: some View {
        let location = Location.template()
        MapPageView(location: location)
    }
}
