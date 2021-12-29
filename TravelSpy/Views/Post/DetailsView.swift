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
    var post: Post
    private let imageHeight: CGFloat = 400
    private let collapsedImageHeight: CGFloat = 75
    
    @ObservedObject private var articleContent: ViewFrame = ViewFrame()
    @State private var titleRect: CGRect = .zero
    @State private var headerImageRect: CGRect = .zero
    @State private var isShowMap = false
    
    func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let sizeOffScreen = imageHeight - collapsedImageHeight
        
        // if our offset is roughly less than -225 (the amount scrolled / amount off screen)
        if offset < -sizeOffScreen {
            // Since we want 75 px fixed on the screen we get our offset of -225 or anything less than. Take the abs value of
            let imageOffset = abs(min(-sizeOffScreen, offset))
            
            // Now we can the amount of offset above our size off screen. So if we've scrolled -250px our size offscreen is -225px we offset our image by an additional 25 px to put it back at the amount needed to remain offscreen/amount on screen.
            return imageOffset - sizeOffScreen
        }
        
        // Image was pulled down
        if offset > 0 {
            return -offset
            
        }
        
        return 0
    }
    
    func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        if offset > 0 {
            return imageHeight + offset
        }
        
        return imageHeight
    }
    
    // at 0 offset our blur will be 0
    // at 300 offset our blur will be 6
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height // (values will range from 0 - 1)
        
        return blur * 6 // Values will range from 0 - 6
    }
    
    // 1
    //    private func getHeaderTitleOffset() -> CGFloat {
    //        let currentYPos = titleRect.midY
    //
    //        // (x - min) / (max - min) -> Normalize our values between 0 and 1
    //
    //        // If our Title has surpassed the bottom of our image at the top
    //        // Current Y POS will start at 75 in the beggining. We essentially only want to offset our 'Title' about 30px.
    //        if currentYPos < headerImageRect.maxY {
    //            let minYValue: CGFloat = 50.0 // What we consider our min for our scroll offset
    //            let maxYValue: CGFloat = collapsedImageHeight // What we start at for our scroll offset (75)
    //            let currentYValue = currentYPos
    //
    //            let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue)) // Normalize our values from 75 - 50 to be between 0 to -1, If scrolled past that, just default to -1
    //            let finalOffset: CGFloat = -30.0 // We want our final offset to be -30 from the bottom of the image header view
    //            // We will start at 20 pixels from the bottom (under our sticky header)
    //            // At the beginning, our percentage will be 0, with this resulting in 20 - (x * -30)
    //            // as x increases, our offset will go from 20 to 0 to -30, thus translating our title from 20px to -30px.
    //
    //            return 20 - (percentage * finalOffset)
    //        }
    //
    //        return .infinity
    //    }
    
    var body: some View {
        VStack {
            if isShowMap {
                GeometryReader { geometry in
                    ZStack {
                        MapView(post: post)
                            .ignoresSafeArea()
                        VStack {
                            
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    print("Tapped")
                                    isShowMap.toggle()
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color.white.opacity(0.95))
                                        .padding()
                                        .padding(.top, 30)
                                        .padding(.trailing, 20)
                                }
                            }
                            .frame(width: geometry.size.width, height: 50)
                            .background(Color.primary.opacity(0.4))
                        }
                    }
                }
            } else {
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "person")
                                    .resizable()
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
                                }
                            }
                            
                            HStack {
                                Text(post.createdAt.formatted(.dateTime.year().month(.wide).day()))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                Button(action: {
                                    self.isShowMap.toggle()
                                }, label: {
                                    Text("\(post.countryAndCity)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                })
                            }
                            
                            Text(post.content)
                                .lineLimit(nil)
                        }
                        .padding(.horizontal)
                    }
                    .offset(y: imageHeight + 16)
                    .background(GeometryGetter(rect: $articleContent.frame))
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .bottom) {
                            VStack {
                                ImageLoadingView(url: post.imageUrl!)
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                                    .blur(radius: self.getBlurRadiusForImage(geometry))
                                    .clipped()
                                    .background(GeometryGetter(rect: self.$headerImageRect))
                            }
                            
                        }
                        .clipped()
                        .offset(x: 0, y: 50 + self.getOffsetForHeaderImage(geometry))
                    }
                    .frame(height: imageHeight)
                    .offset(x: 0, y: -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
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

class ViewFrame: ObservableObject {
    var startingRect: CGRect?
    
    @Published var frame: CGRect {
        willSet {
            if startingRect == nil {
                startingRect = newValue
            }
        }
    }
    
    init() {
        self.frame = .zero
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            AnyView(Color.clear)
                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
        }
        .onPreferenceChange(RectanglePreferenceKey.self) { (value) in
            self.rect = value
        }
    }
}

struct RectanglePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
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
