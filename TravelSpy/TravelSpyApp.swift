//
//  TravelSpyApp.swift
//  TravelSpy
//
//  Created by AlexK on 25/11/2021.
//

import SwiftUI
import Firebase

// Appearance: light ony # in Info.plist

@main
struct TravelSpyApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var sessionStore = SessionStore()
    @StateObject var viewRouter = ViewRouter()
    @StateObject var postsModel = PostsModel()
    @StateObject var viewAlertModel = AlertViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {        
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(sessionStore)
                .environmentObject(viewRouter)
                .environmentObject(postsModel)
                .environmentObject(viewAlertModel)
                .toast(isPresenting: $viewAlertModel.show, duration: 0.0, tapToDismiss: true) {
                    viewAlertModel.alertToast
                }
        }
    }
}
