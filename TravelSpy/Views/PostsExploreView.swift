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
    @State private var showDetailedView = false
    @State private var detailedForPost: Post?
    
    var body: some View {
        ScrollView(showsIndicators: true) {
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
                            
                            HStack() {
                                VStack(alignment: .leading) {
                                    Text(post.locationCountry)
                                        .font(.system(size: 9))
                                        .foregroundColor(.primary)
                                    Text(post.locationCity)
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
                            fetchPreviousPosts()
                        }
                }
            }
        }
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
    
    private func openDetailedView(post: Post) {
        detailedForPost = post
        showDetailedView = true
    }
}

struct PostsExploreView_Previews: PreviewProvider {
    static var previews: some View {
        PostsExploreView()
    }
}
