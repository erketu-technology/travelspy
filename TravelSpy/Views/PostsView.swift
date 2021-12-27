//
//  PostsView.swift
//  TravelSpy
//
//  Created by AlexK on 25/11/2021.
//

import SwiftUI
//import CoreData
import Firebase

//import CloudKit

//import YPImagePicker

struct PostsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //    @State private var isShowPhotoLibrary = false
    //    @State private var image = UIImage()
    
    //    @AppStorage("login") private var login = false
    @AppStorage("isShowPostCreation") public var isShowPostCreation = false
    
    @State private var postItems: [Post] = []
    @State var postsModel = PostsModel()
    @State var profile: UserProfile?
    
    @EnvironmentObject var sessionStore: SessionStore
    let currentUser = Auth.auth().currentUser
    
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
        NavigationView {
            VStack {
                VStack {
                    if postItems.isEmpty {
                        ScrollView {
                            VStack {
                                LoadingPostView()
                                LoadingPostView()
                                LoadingPostView()
                            }
                        }
                    } else {
                        List(postItems, id: \.id) { post in
                            VStack (alignment: .leading) {
                                if post.uid.isEmpty && postsModel.isFetching {
                                    LoadingPostView()
                                } else if !post.uid.isEmpty {
                                    PostRowView(post: post)
                                        .onAppear {
                                            if self.postsModel.isLastPost(post) {
                                                self.loadPosts()
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
                        .edgesIgnoringSafeArea(.top)
                        .refreshable { refresh() }
                        .listStyle(GroupedListStyle())
                        //                .onAppear(perform: {
                        //                    UITableView.appearance().contentInset.top = -43
                        //                })
                    }
                }
                .onAppear {
                    URLCache.shared.memoryCapacity = 1024 * 1024 * 512
                    refresh()
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        isShowPostCreation.toggle()
                    }) {
                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                    }
                }
                .fullScreenCover(isPresented: $isShowPostCreation, onDismiss: {
                    print("REFRESH DATA")
                }, content: {
                    TSImagePicker()
                })
            }
            .onAppear {
//                fetchProfile()
            }
            .navigationTitle("Name")
            .navigationBarTitleDisplayMode(.inline)
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
    }
    
    private func fetchProfile() {
        sessionStore.fetchProfile { _, error in
            if error != nil {
                print("###Error: fetchProfile \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    private func refresh() {
        postsModel.refreshAll { postItems in
            self.postItems = postItems
        }
    }
    
    private func loadPosts() {
        postsModel.fetch() { postItems in
            self.postItems = postItems
            
        }
    }
    
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        //        PostsView().preferredColorScheme(.dark).previewInterfaceOrientation(.portrait).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        PostsView().previewInterfaceOrientation(.portrait).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
