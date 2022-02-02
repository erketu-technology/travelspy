//
//  UserView.swift
//  TravelSpy
//
//  Created by AlexK on 26/01/2022.
//

import SwiftUI
import WaterfallGrid

struct UserView: View {
    
    let profile: UserProfile
    @StateObject var profileModel: ExternalUserPostsModel
    
    
    init(profile: UserProfile) {
        self.profile = profile
        _profileModel = StateObject(wrappedValue: ExternalUserPostsModel(uid: profile.uid))
    }
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "person")
                        .resizable()
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
                    WaterfallGrid(profileModel.posts) { post in
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
                    
                    if profileModel.posts.count < profileModel.totalCount {
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
            .navigationTitle(profile.userName)
            .navigationBarItems(trailing: Button(action: {
                followUser()
            }) {
                Text("Follow")
            })
        }
    }
    
    private func fetchPosts() {
        profileModel.fetchTotalCount()
        Task {
            await profileModel.fetchPosts()
        }
    }
    
    private func fetchPreviousPosts() {
        Task {
            await profileModel.fetchPreviousPosts(limit: 10)
        }
    }

    private func followUser() {
        
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = UserProfile.template()
        UserView(profile: profile)
    }
}
