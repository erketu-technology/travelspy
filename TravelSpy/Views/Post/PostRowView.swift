//
//  PostRowView.swift
//  TravelSpy
//
//  Created by AlexK on 24/12/2021.
//

import SwiftUI

struct PostRowView: View {
    var post: Post
    
    @State var isTruncated = false
    @State private var showDetailedView = false
    @State private var detailedForPost: Post?
    
    var body: some View {
        VStack {
            if post.imageUrl != nil {
                ImageLoadingView(url: post.imageUrl!)                    
                    .scaledToFill()
                    .frame(height: 400)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            VStack (alignment: .leading, spacing: 4) {
                TruncableTextView(
                    text: Text(post.content),
                    lineLimit: 4
                ) {
                    isTruncated = $0
                }
                .font(.caption)
                .textSelection(.enabled)
                .onTapGesture {
                    openDetailedView(post: post)
                }
                
                HStack {
                    Text(post.createdAt.timeAgoSinceDate())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .clipped()
                    
                    if isTruncated {
                        Spacer()
                        Button("read more") {
                            openDetailedView(post: post)
                        }
                        .clipped()
                        .font(.caption)
                        .buttonStyle(BorderlessButtonStyle())
//                        .fullScreenCover(item: $detailedForPost) { item in
//                            DetailsView(post: item)
//                        }
                        .sheet(item: $detailedForPost) { item in
                            DetailsView(post: item)
                        }
                    }
                }
            }
            .clipped()
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
    }
    
    private func openDetailedView(post: Post) {
        detailedForPost = post
        showDetailedView = true
    }
}

struct PostRowView_Previews: PreviewProvider {
    static var previews: some View {
        let post = Post.template()
        PostRowView(post: post)
    }
}
