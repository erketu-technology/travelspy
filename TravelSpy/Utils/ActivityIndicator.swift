//
//  ActivityIndicator.swift
//  TravelSpy
//
//  Created by AlexK on 31/12/2021.
//

import SwiftUI

struct ActivityIndicator<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                if (!self.isShowing) {
                    self.content()
                } else {
                    self.content()
                        .disabled(true)
                        .blur(radius: 3)

                    VStack {
                        Text("Loading ...")
                        ProgressView()
                    }
                    .frame(width: geometry.size.width / 2.0, height: 200.0)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                }
            }
        }
    }
}

#if DEBUG
struct ActivityIndicator_Previews: PreviewProvider {

    static var previews: some View {
        ActivityIndicator(isShowing: .constant(true)) {
            NavigationView {
                Text("Hello World")
                    .navigationBarTitle(Text("List"), displayMode: .large)
            }
        }
    }
}
#endif
