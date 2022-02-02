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
    
    init() {
        self.isShowPostCreation = false
    }
    //            HStack {
    //                Spacer()
    //                Text("Name")
    //                    .padding(.leading, 30)
    //                Spacer()
    //                Menu {
    //                    Button("Log Out", action: { sessionStore.signOut() } )
    //                } label: {
    //                    let username: String = self.sessionStore.profile?.userName ?? " "
    //                    Text(String(username.first!.uppercased()))
    //                        .frame(width: 20, height: 20, alignment: .center)
    //                        .padding()
    //                        .overlay(
    //                            Circle()
    //                                .stroke(Color.gray, lineWidth: 1)
    //                                .padding(5)
    //                        )
    //                        .padding(.trailing, 10)
    //                        .foregroundColor(Color.primary)
    //                }
    //            }
    
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
//                    .edgesIgnoringSafeArea(.top)
                    .refreshable { fetchNextPosts() }
                    .listStyle(GroupedListStyle())
                    //                .onAppear(perform: {
                    //                    UITableView.appearance().contentInset.top = -43
                    //                })
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
            let username: String = self.sessionStore.profile?.userName ?? " "
            NavigationLink {
                PreferencesView(profile: sessionStore.profile)
            } label: {
                Text(String(username.first!.uppercased()))
                    .frame(width: 15, height: 15, alignment: .center)
                    .padding()
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .padding(5)
                    )
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
