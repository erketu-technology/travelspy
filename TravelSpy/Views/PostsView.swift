//
//  PostsView.swift
//  TravelSpy
//
//  Created by AlexK on 25/11/2021.
//

import SwiftUI
import Firebase
import SwiftUIPager

struct PostsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var userPostsModel: UserPostsModel
    
    @AppStorage("isShowPostCreation") public var isShowPostCreation = false
    
    @State var profile: UserProfile?    
    
    var body: some View {
        if isLoggedIn() {
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
            .navigationTitle("TravelSpy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(trailing: HStack {
                if isLoggedIn() {
                    NavigationLink {
                        AccountView()
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundColor(Color.primary)
                    }
                } else {
                    EmptyView()
                }
            })
        } else {
            VStack {
                NavigationLink {
                    LoginView()
                } label: {
                    VStack {
                        Text("Please, log in to see the newsfeed.")
                        Text("Log In")
                            .foregroundColor(Color.blue)
                    }
                }
            }
        }
    }

    private func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
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
