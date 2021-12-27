//
//  LoadingPostView.swift
//  TravelSpy
//
//  Created by AlexK on 26/12/2021.
//

import SwiftUI

struct LoadingPostView: View {
    @State private var offset: CGFloat = -350
    
    var body: some View {
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color.primary.opacity(0.09))
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                Rectangle()
                    .fill(Color.primary.opacity(0.09))
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            }
            VStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.6))
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                Rectangle()
                    .fill(Color.secondary.opacity(0.6))
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            }
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 0.7).repeatForever(autoreverses: false)) {
                        self.offset += 1000
                    }
                }
            }
            .mask(
                Rectangle()
                    .fill(Color.secondary.opacity(0.6))
                    .rotationEffect(.init(degrees: 70))
                    .offset(x: self.offset)

            )
        }
    }
}

struct LoadingPostView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingPostView()
        LoadingPostView()
            .preferredColorScheme(.dark)
    }
}
