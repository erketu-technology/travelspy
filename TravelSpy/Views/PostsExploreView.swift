//
//  PostsExploreView.swift
//  TravelSpy
//
//  Created by AlexK on 28/12/2021.
//

import SwiftUI
import WaterfallGrid

struct PostsExploreView: View {
    @StateObject var postsModel = PostsModel()
    @State var isTruncated = false
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            LazyVStack {
                WaterfallGrid(postsModel.posts) { post in
                    NavigationLink(destination: DetailsView(post: post)) {
                        ZStack {
                            VStack {
                                if !post.uid.isEmpty {
                                    if post.imageUrl != nil {
                                        ImageLoadingView(url: post.imageUrl!)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 80)
                                            .clipped()
                                    }

                                    HStack() {
                                        VStack(alignment: .leading) {
                                            Text(post.location.country)
                                                .font(.system(size: 9))
                                                .foregroundColor(.primary)
                                            Text(post.location.city)
                                                .font(.system(size: 9))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding([.leading, .trailing, .bottom], 5)
                                }
                            }
                            .cornerRadius(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.5))
                            )
                        }
                    }
                }
                .gridStyle(
                    //                    columns: 4,
                    spacing: 5,
                    animation: .easeInOut(duration: 0.5)
                )
                .padding(EdgeInsets(top: 16, leading: 5, bottom: 70, trailing: 1))
                
                if postsModel.posts.count < postsModel.totalCount {
                    ProgressView()
                        .frame(height: 40)
                        .onAppear {
                            fetchPreviousPosts()
                        }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .onAppear {
            postsModel.fetchTotalCount()
            fetchPosts()
        }
    }
    
    private func fetchPreviousPosts() {
        Task {
            await postsModel.fetchPreviousPosts(limit: 10)
        }
        
    }
    
    private func fetchPosts() {
        Task.init {
            await postsModel.fetchPosts(limit: 30)
        }
    }
}

struct PostsExploreView_Previews: PreviewProvider {
    static var previews: some View {
        PostsExploreView()
    }
}
