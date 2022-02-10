//
//  DetailsView.swift
//  TravelSpy
//
//  Created by AlexK on 23/12/2021.
//

import SwiftUI
import Firebase
import MapKit

struct DetailsView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    var post: Post
    private let imageHeight: CGFloat = 400

    @State private var isShowLocation = false
    @State var isLinkActive = false
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            ImageLoadingView(url: post.imageUrl!)
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: imageHeight)
                                .clipped()

                            ZStack {
                                Button(action: {
                                    self.isLinkActive = true
                                }) {
                                    HStack {
                                        ImageLoadingView(url: sessionStore.profile?.avatar)
                                            .scaledToFill()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .shadow(radius: 4)
                                            .padding(.top, 10)

                                        VStack(alignment: .leading) {
                                            Text("Article Written By")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 12))
                                            Text(post.user.userName)
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding(.horizontal)

                                NavigationLink(destination: UserView(profile: post.user), isActive: $isLinkActive) {}
                                .opacity(0.0)
                                .buttonStyle(PlainButtonStyle())
                            }

                            HStack {
                                Text(post.createdAt.formatted(.dateTime.year().month(.wide).day()))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)

                                Spacer()
                                Button(action: {
                                    self.isShowLocation = true
                                }, label: {
                                    Text("\(post.countryAndCity)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                })
                                NavigationLink(destination: MapPageView(location: post.location), isActive: $isShowLocation) {}
                                .opacity(0.0)
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)

                            Text(post.content)
                                .lineLimit(nil)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(post: Post.template(content: loremIpsum))
    }
}

let loremIpsum = """
Lorem ipsum dolor sit amet consectetur adipiscing elit donec, gravida commodo hac non mattis augue duis vitae inceptos, laoreet taciti at vehicula cum arcu dictum. Cras netus vivamus sociis pulvinar est erat, quisque imperdiet velit a justo maecenas, pretium gravida ut himenaeos nam. Tellus quis libero sociis class nec hendrerit, id proin facilisis praesent bibendum vehicula tristique, fringilla augue vitae primis turpis.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
"""
