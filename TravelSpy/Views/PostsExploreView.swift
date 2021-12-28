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
                    VStack() {
                        ImageLoadingView(url: post.imageUrl!)
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 80)
                            .clipped()
                        
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
                    .cornerRadius(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.5))
                    )
                }
                .gridStyle(
                    columns: 4,
                    spacing: 3,
                    animation: .easeInOut(duration: 0.5)
                )
                .padding(EdgeInsets(top: 16, leading: 5, bottom: 16, trailing: 1))
                
                if postsModel.posts.count < postsModel.totalCount {
                    ProgressView()
                        .frame(height: 80)
                        .onAppear {
                            postsModel.fetchNextPosts()
                        }
                }
            }
        }
        .onAppear {
            postsModel.fetchTotalCount()
            postsModel.fetchPosts()
        }
    }
}

struct PostsExploreView_Previews: PreviewProvider {
    static var previews: some View {
        PostsExploreView()
    }
}
