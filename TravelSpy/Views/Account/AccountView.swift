//
//  AccountView.swift
//  TravelSpy
//
//  Created by AlexK on 03/02/2022.
//

import SwiftUI
import WaterfallGrid

struct AccountView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @StateObject var userPostsModel: CurrentUserPostsModel

    @State var isShowAccountImageCreation = false

    init() {
        _userPostsModel = StateObject(wrappedValue: CurrentUserPostsModel())
    }

    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()

                    Button {
                        self.isShowAccountImageCreation = true
                    } label: {
                        ImageLoadingView(url: sessionStore.profile?.avatar)
                            .scaledToFill()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .foregroundColor(Color.black)
                    }
                    NavigationLink(isActive: $isShowAccountImageCreation, destination: {
                        TSImagePicker(imageType: .account)
                            .navigationBarHidden(true)
                    }) {}
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())

                    Text(sessionStore.profile!.userName)
                        .padding(.horizontal, 15)

                    Spacer()
                }

                Divider()

                LazyVStack {
                    WaterfallGrid(userPostsModel.posts) { post in
                        VStack {
                            if !post.uid.isEmpty {
                                if post.imageUrl != nil {
                                    ImageLoadingView(url: post.imageUrl!)
                                        .aspectRatio(contentMode: .fill)
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
//                                                .onTapGesture {
//                                                    openDetailedView(post: post)
//                                                }
                        //                        .sheet(item: $detailedForPost) { item in
                        //                            DetailsView(post: item)
                        //                        }
                    }
                    .gridStyle(
                        columns: 4,
                        spacing: 5,
                        animation: .easeInOut(duration: 0.5)
                    )
                    .padding(EdgeInsets(top: 16, leading: 5, bottom: 70, trailing: 1))

                    if userPostsModel.posts.count < userPostsModel.totalCount {
                        ProgressView()
                            .frame(height: 40)
                            .onAppear {
                                fetchPreviousPosts()
                            }
                    }
                }
            }
            .onAppear {
                fetchPosts()
            }
            .padding([.vertical, .horizontal], 10)
            .navigationTitle("")
            .navigationBarItems(trailing:
                NavigationLink {
                    PreferencesView(profile: sessionStore.profile)
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(Color.primary)
                }
            )
        }
    }

    private func fetchPreviousPosts() {
        Task {
            await userPostsModel.fetchPreviousPosts(limit: 10)
        }
    }

    private func fetchPosts() {
        print("### fetchPosts")
        userPostsModel.fetchTotalCount()
        Task {
            await userPostsModel.fetchPosts()
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
