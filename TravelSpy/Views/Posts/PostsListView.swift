//
//  UserPostsListView.swift
//  TravelSpy
//
//  Created by AlexK on 16/02/2022.
//

import SwiftUI
import WaterfallGrid

struct PostsListView: View {

    let posts: [Post]
    let totalCount: Int

    let fetchPreviousPosts: () -> ()

    var body: some View {
        LazyVStack {
            WaterfallGrid(posts) { post in
                NavigationLink(destination: DetailsView(post: post)) {
                    VStack {
                        if !post.uid.isEmpty {
                            if post.imageUrl != nil {
                                ImageLoadingView(url: post.imageUrl!)
                                    .scaledToFill()
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
                }
            }
            .gridStyle(
                spacing: 5,
                animation: .easeInOut(duration: 0.5)
            )
            .padding(EdgeInsets(top: 16, leading: 5, bottom: 70, trailing: 1))

            if posts.count < totalCount {
                ProgressView()
                    .frame(height: 40)
                    .onAppear {
                        fetchPreviousPosts()
                    }
            }
        }
    }
}

struct PostsListView_Previews: PreviewProvider {
    static var previews: some View {
        PostsListView(posts: [], totalCount: 0) { }
    }
}
