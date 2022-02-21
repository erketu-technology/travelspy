//
//  UserView.swift
//  TravelSpy
//
//  Created by AlexK on 26/01/2022.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var sessionStore: SessionStore    

    let profile: UserProfile
    @EnvironmentObject var userPostsModel: UserPostsModel
    @StateObject var eUserPostsModel: ExternalUserPostsModel    

    init(profile: UserProfile) {
        self.profile = profile
        _eUserPostsModel = StateObject(wrappedValue: ExternalUserPostsModel(uid: profile.uid))
    }
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    ImageLoadingView(url: profile.avatar)
                        .scaledToFill()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                        .foregroundColor(Color.black)
                    Text(profile.userName)
                    Spacer()
                }
                
                Divider()
                
                PostsListView(posts: eUserPostsModel.posts, totalCount: eUserPostsModel.totalCount) {
                    fetchPreviousPosts()
                }
            }
            .onAppear {
                fetchPosts()
            }
            .padding([.vertical, .horizontal], 10)
            .navigationTitle("")
            .navigationBarItems(trailing: Group {
                if sessionStore.isLoggedIn {
                    Button(action: {
                        followUser()
                    }) {
                        Text(isFollowUser() ? "Unfollow" : "Follow")
                    }
                } else { EmptyView() }
            })
        }
    }    
    
    private func fetchPosts() {
        eUserPostsModel.fetchTotalCount()
        Task {
            await eUserPostsModel.fetchPosts()
        }
    }
    
    private func fetchPreviousPosts() {
        Task {
            await eUserPostsModel.fetchPreviousPosts(limit: 10)
        }
    }

    private func isFollowUser() -> Bool {
        return sessionStore.profile!.usersFollowing.contains(profile.uid)
    }

    private func followUser() {
        Task.init {
            let action: SessionStore.FollowAction = isFollowUser() ? .unfollow : .follow
            await sessionStore.followUser(profile, action: action)
            userPostsModel.removeAll()
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = UserProfile.template()
        UserView(profile: profile)
    }
}
