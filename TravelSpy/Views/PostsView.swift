//
//  PostsView.swift
//  TravelSpy
//
//  Created by AlexK on 25/11/2021.
//

import SwiftUI
import Firebase

struct PostsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var userPostsModel: UserPostsModel
    
    @AppStorage("isShowPostCreation") public var isShowPostCreation = false
    
    @State var profile: UserProfile?
    @State private var firstTime: Bool = true
    @State private var didAppearTimeInterval: TimeInterval = 0
    
    var body: some View {
        ZStack {
            VStack {
                if userPostsModel.posts.isEmpty {
                    ScrollView {
                        VStack {
                            LoadingPostView()
                            LoadingPostView()
                            LoadingPostView()
                        }
                    }
                } else {
                    List(userPostsModel.posts, id: \.id) { post in
                        VStack (alignment: .leading) {
                            if post.uid.isEmpty && userPostsModel.isFetching {
                                LoadingPostView()
                            } else if !post.uid.isEmpty {
                                PostRowView(post: post)
                                    .onAppear {
                                        if self.userPostsModel.isLastPost(post) {
                                            self.fetchPreviousPosts()
                                        }
                                    }
                            }
                        }
                        .padding(.bottom, 24)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .edgesIgnoringSafeArea(.horizontal)
                    }
                    .refreshable { fetchNextPosts() }
                    .listStyle(GroupedListStyle())
                }
            }
            .onAppear {
                URLCache.shared.memoryCapacity = 1024 * 1024 * 512
            }
            .onDisappear {
                userPostsModel.detachListener()
            }
        }
        .onAppear {
            self.fetchData()
        }
        .navigationTitle("Name")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(trailing: HStack {
            NavigationLink {
                AccountView()
            } label: {
                Image(systemName: "person.circle")
                    .foregroundColor(Color.primary)
            }
        })
    }
    
    private func fetchData() {
        if !userPostsModel.posts.isEmpty { return }

        sessionStore.fetchProfile { profile, error in
            if error != nil {
                print("###Error: fetchProfile \(String(describing: error?.localizedDescription))")
            }

            guard profile != nil else { return }
            userPostsModel.fetchTotalCount()
            Task.init {
                await userPostsModel.fetchPosts()
            }
        }
    }
    
    private func fetchNextPosts() {
        Task.init {
            await userPostsModel.fetchNextPosts()
        }
    }
    
    private func fetchPreviousPosts() {
        Task.init {
            await userPostsModel.fetchPreviousPosts()
        }
    }
    
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        //        PostsView().preferredColorScheme(.dark).previewInterfaceOrientation(.portrait).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        PostsView().previewInterfaceOrientation(.portrait).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
