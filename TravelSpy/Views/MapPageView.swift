//
//  MapPageView.swift
//  TravelSpy
//
//  Created by AlexK on 12/01/2022.
//

import SwiftUI
import Firebase

struct MapPageView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var viewAlertModel: AlertViewModel
    @EnvironmentObject var userPostsModel: UserPostsModel
    
    @StateObject var postsModel = PostsModel()
    
    let location: Location
    let currentUser = Auth.auth().currentUser

    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack {
                MapView(location: location)
                    .frame(height: 300)

                PostsListView(posts: postsModel.posts, totalCount: postsModel.totalCount) {
                    fetchPreviousPosts()
                }
            }
        }
        .onAppear {
            fetchPosts()
        }
        .navigationTitle(location.countryAndCity)
        .navigationBarItems(
            trailing: Group {
                if currentUser != nil {
                    Button(action: {
                        followLocation()
                    }) {
                        Text(isFollowLocation() ? "Unfollow" : "Follow")
                    }
                } else { EmptyView() }
            }
        )
    }

    private func fetchPreviousPosts() {
        Task {
            await postsModel.fetchPreviousPosts(limit: 10)
        }
    }

    private func isFollowLocation() -> Bool {
        return sessionStore.profile!.locationsFollowing.contains(location.key)
    }

    private func followLocation() {
        Task {
            let action: SessionStore.FollowAction = isFollowLocation() ? .unfollow : .follow
            await sessionStore.followLocation(location, action: action)
            userPostsModel.removeAll()

            let actionMessage = isFollowLocation() ? "follow" : "unfollow"
            self.viewAlertModel.setAlert(status: .success, title: "You have \(actionMessage) the location.")
        }
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
