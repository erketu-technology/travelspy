//
//  ImageLoadingView.swift
//  TravelSpy
//
//  Created by AlexK on 24/12/2021.
//

import SwiftUI

struct ImageLoadingView: View {
    @StateObject var imageLoader: ImageLoader
    
    let imageSize: CGFloat = 400
    
    init(url: String?) {
        self._imageLoader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if imageLoader.image != nil {
                Image(uiImage: imageLoader.image!)
                    .resizable()
            } else if imageLoader.errorMessage != nil {
                Text(imageLoader.errorMessage!)
            } else {
                ProgressView()
                    .frame(height: imageSize)
            }
        }
        .onAppear {
            imageLoader.fetch()
        }
    }
}

struct ImageLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ImageLoadingView(url: nil)
    }
}
