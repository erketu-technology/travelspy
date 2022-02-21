//
//  PostRowView.swift
//  TravelSpy
//
//  Created by AlexK on 24/12/2021.
//

import SwiftUI
import MapKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

struct PostRowView: View {
    @EnvironmentObject var userPostsModel: UserPostsModel
    @EnvironmentObject var sessionStore: SessionStore

    var post: Post
    
    @State var isTruncated = false
    @State var isLinkActive = false
    @State var isPostActive = false
    @State var isUserLinkActive = false

    @State private var locationImage: UIImage? = nil
    
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    VStack {
                        if post.imageUrl != nil {
                            ImageLoadingView(url: post.imageUrl!)
                                .frame(height: 400)
                                .frame(maxWidth: .infinity)
//                                .scaledToFill()
                                .clipped()
                        }
                    }
//                    .clipped()

                    VStack {
                        Button(action: {
                            self.isLinkActive = true
                        }) {
                            VStack {
                                HStack {
                                    if let image = locationImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 30, height: 30)
//                                            .scaledToFill()
                                            .cornerRadius(20)
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    } else {
                                        Circle().stroke(Color.gray, lineWidth: 1)
                                            .frame(width: 30, height: 30)
                                    }
                                    Text(post.countryAndCity)
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 12))
                                    Spacer()
                                }
                                .padding(.leading, 16)
                                .padding(.vertical, 5)
                                .clipped()
                                .onAppear {
                                    generateSnapshot(width: 300, height: 300)
                                }
                                .background(Color.black.opacity(0.4))

                                Spacer()
                            }
                        }
                        NavigationLink(destination: MapPageView(location: post.location), isActive: $isLinkActive) {}
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        .buttonStyle(BorderlessButtonStyle())

//                        Spacer()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Button(action: {
                    self.isUserLinkActive = true
                }) {
                    HStack {
                        ImageLoadingView(url: post.user.avatar)
                            .scaledToFill()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 15, height: 15)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .foregroundColor(Color.black)
                        Text(post.user.userName)
                            .foregroundColor(Color.black)
                            .font(.caption)
                            .bold()
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.gray)

                        Text(post.createdAt.timeAgoSinceDate())
                            .font(.caption)
                            .foregroundColor(.gray)
                            .clipped()
                    }
                    .padding(.vertical, 3)

                    NavigationLink(destination: selectUserView(), isActive: $isUserLinkActive) {}
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                }
                .buttonStyle(BorderlessButtonStyle())

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
                    Spacer()
                    if isTruncated {
                        Spacer()
                        Button("read more") {
                            openDetailedView(post: post)
                        }
                        .clipped()
                        .font(.caption)
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(.blue)
                    }
                }
                NavigationLink(destination: DetailsView(post: post), isActive: $isPostActive) {}
                .opacity(0.0)
                .buttonStyle(PlainButtonStyle())
            }
            .clipped()
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
        .padding(.bottom, 10)
        .background(Color.white)
    }
    
    private func openDetailedView(post: Post) {
        self.isPostActive = true
    }

    private func selectUserView() -> some View {
        return (
            post.user.uid == sessionStore.currentUser?.uid
        ) ? AnyView(AccountView()) : AnyView(UserView(profile: post.user))
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)
        let span: CLLocationDegrees = 0.01
        
        // The region the map should display.
        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        )
        
        // Map options.
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        //        mapOptions.mapType = .hybrid
        
        // Create the snapshotter and run it.
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                print(error)
                return
            }
            if let snapshot = snapshotOrNil {
                self.locationImage = snapshot.image
            }
        }
    }
}

struct PostRowView_Previews: PreviewProvider {
    static var previews: some View {
        let post = Post.template(content: loremIpsumTemplate)
        PostRowView(post: post)
    }
}

let loremIpsumTemplate = """
Lorem ipsum dolor sit amet consectetur adipiscing elit donec, gravida commodo hac non mattis augue duis vitae inceptos, laoreet taciti at vehicula cum arcu dictum. Cras netus vivamus sociis pulvinar est erat, quisque imperdiet velit a justo maecenas, pretium gravida ut himenaeos nam. Tellus quis libero sociis class nec hendrerit, id proin facilisis praesent bibendum vehicula tristique, fringilla augue vitae primis turpis.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
"""
