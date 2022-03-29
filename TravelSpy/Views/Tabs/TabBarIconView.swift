//
//  TabBarIconView.swift
//  TravelSpy
//
//  Created by AlexK on 28/12/2021.
//

import SwiftUI

struct TabBarIconView: View {
    @EnvironmentObject var viewRouter: ViewRouter

    let assignedPage: TSPage
    let systemIconName: String

    var body: some View {
        VStack {
            Image(systemName: viewRouter.currentPage == assignedPage ? systemIconName + ".fill" : systemIconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .onTapGesture {
                    viewRouter.currentPage = assignedPage
                }
                .foregroundColor(Color.white)
        }
    }
}

struct TabBarIconView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarIconView(assignedPage: .explore, systemIconName: "magnifyingglass.circle")
    }
}
