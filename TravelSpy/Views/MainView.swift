//
//  MainView.swift
//  TravelSpy
//
//  Created by AlexK on 14/12/2021.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        switch sessionStore.state {
        case .signedIn: PostsView()
        case .signedOut: LoginView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
