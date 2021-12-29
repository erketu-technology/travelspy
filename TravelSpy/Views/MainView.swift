//
//  MainView.swift
//  TravelSpy
//
//  Created by AlexK on 14/12/2021.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var viewRouter: ViewRouter
    @AppStorage("isShowPostCreation") public var isShowPostCreation = false
    
    var body: some View {
        GeometryReader { geometry in
            if (sessionStore.state == .signedIn) {
                NavigationView {
                    ZStack {
                        switch viewRouter.currentPage {
                        case .explore:
                            PostsExploreView()
                        case .list:
                            PostsView()
                        }
                        
                        VStack {
                            Spacer()
                            
                            ZStack {
                                HStack(spacing: 180) {
                                    TabBarIconView(assignedPage: .explore, systemIconName: "magnifyingglass.circle")
                                    TabBarIconView(assignedPage: .list, systemIconName: "list.bullet.rectangle")
                                }
                                .frame(width: geometry.size.width - 20, height: 50)
                                .padding(.bottom, 0)
                                .background(Color.secondary.opacity(0.9))
                                .cornerRadius(15)
                                
                                HStack {
                                    Button(action: {
                                        self.isShowPostCreation.toggle()
                                    }) {
                                        Image(systemName: "camera.metering.partial")
                                            .resizable()
                                            .foregroundColor(Color.white)
                                            .frame(width: 40, height: 30)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(Color(red: 0.331, green: 0.184, blue: 0.457))
                                .clipShape(
                                    Circle()
                                )
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 10)
                                .offset(y: -geometry.size.height/8/4)
                                .fullScreenCover(isPresented: $isShowPostCreation) {
                                    TSImagePicker()
                                }
                            }
                        }
                    }
                }
            } else {
                LoginView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
