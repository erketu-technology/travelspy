//
//  PostRowView.swift
//  TravelSpy
//
//  Created by AlexK on 24/12/2021.
//

import SwiftUI
import MapKit

struct PostRowView: View {
    var post: Post
    
    @State var isTruncated = false
    @State private var showDetailedView = false
    @State private var detailedForPost: Post?
    @State var isLinkActive = false
    @State private var locationImage: UIImage? = nil
    
    var body: some View {
        VStack {
            Button(action: {
                self.isLinkActive = true
            }) {
                ZStack {
                    HStack {
                        if let image = locationImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .scaledToFill()
                                .cornerRadius(20)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } else {
                            Circle().stroke(Color.gray, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        }
                        Text(post.countryAndCity)
                            .foregroundColor(Color.black)
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .clipped()
                    .onAppear {
                        generateSnapshot(width: 300, height: 300)
                    }
                    NavigationLink(destination: MapPageView(location: post.location), isActive: $isLinkActive) {}
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            HStack {
                if post.imageUrl != nil {
                    ImageLoadingView(url: post.imageUrl!)
                        .frame(height: 400)
                        .frame(maxWidth: .infinity)
                        .scaledToFill()
                        .clipped()
                }
            }.clipped()
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
        let post = Post.template()
        PostRowView(post: post)
    }
}
