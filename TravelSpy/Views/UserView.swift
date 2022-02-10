//
//  UserView.swift
//  TravelSpy
//
//  Created by AlexK on 26/01/2022.
//

import SwiftUI
import WaterfallGrid

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
                
                LazyVStack {
                    WaterfallGrid(eUserPostsModel.posts) { post in
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
                        //                        .onTapGesture {
                        //                            openDetailedView(post: post)
                        //                        }
                        //                        .sheet(item: $detailedForPost) { item in
                        //                            DetailsView(post: item)
                        //                        }
                    }
                    .gridStyle(
                        columns: 4,
                        spacing: 5,
                        animation: .easeInOut(duration: 0.5)
                    )
                    .padding(EdgeInsets(top: 16, leading: 5, bottom: 70, trailing: 1))
                    
                    if eUserPostsModel.posts.count < eUserPostsModel.totalCount {
                        ProgressView()
                            .frame(height: 40)
                            .onAppear {
                                fetchPreviousPosts()
                            }
                    }
                }
            }
            .onAppear {
                fetchPosts()
            }
            .padding([.vertical, .horizontal], 10)
            .navigationTitle("")
            .navigationBarItems(trailing: Button(action: {
                followUser()
            }) {
                Text(isFollowUser() ? "Unfollow" : "Follow")
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
