//
//  TSMapView.swift
//  TravelSpy
//
//  Created by AlexK on 12/01/2022.
//

import SwiftUI

struct PostMapView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var userPostsModel: UserPostsModel

    let post: Post
    @Binding var isShowMap: Bool
    
    var body: some View {
        ZStack {
            MapView(location: post.location)
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: {
                        isShowMap.toggle()
                    }) {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.white.opacity(0.95))
                            .padding(7)
                    }
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(5)
                    .padding(.leading, 5)
                    .padding(.top, 5)
                    
                    Spacer()
                }
                
                Spacer()
                HStack {
                    Button(action: {
                        followLocation()
                    }) {
                        HStack {
                            Image(systemName: isFollowLocation() ? "mappin.circle" : "mappin.slash.circle")
                                .foregroundColor(Color.white)
                            Text(isFollowLocation() ? "Followed" : "Follow")
                                .foregroundColor(Color.white)
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal, 15)
                    }
                    .background(Color(red: 0.331, green: 0.184, blue: 0.457))
                    .cornerRadius(5)
                    .padding(.top, 30)
                }
            }
        }
    }

    private func isFollowLocation() -> Bool {
        return sessionStore.profile!.locationsFollowing.contains(post.location.key)
    }
    
    private func followLocation() {
        Task.init {
            let action: SessionStore.LocationAction = isFollowLocation() ? .unfollow : .follow
            await sessionStore.followLocation(post.location, action: action)
            userPostsModel.removeAll()
        }
    }
}

struct TSMapView_Previews: PreviewProvider {
    static var previews: some View {
        PostMapView(post: Post.template(), isShowMap: .constant(false))
    }
}
