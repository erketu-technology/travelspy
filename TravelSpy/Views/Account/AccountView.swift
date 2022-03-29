//
//  AccountView.swift
//  TravelSpy
//
//  Created by AlexK on 03/02/2022.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @StateObject var userPostsModel: CurrentUserPostsModel = CurrentUserPostsModel()

    @State var isShowAccountImageCreation = false

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

                    Text(sessionStore.profile?.userName ?? "")
                        .padding(.horizontal, 15)

                    Spacer()
                }

                Divider()

                PostsListView(posts: userPostsModel.posts, totalCount: userPostsModel.totalCount) {
                    fetchPreviousPosts()
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
        userPostsModel.fetchTotalCount()
        Task {
            await userPostsModel.fetchPosts(limit: 30)
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
