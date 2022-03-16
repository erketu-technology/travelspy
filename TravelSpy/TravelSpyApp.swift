//
//  TravelSpyApp.swift
//  TravelSpy
//
//  Created by AlexK on 25/11/2021.
//

import SwiftUI
import Firebase
import GooglePlaces
import GooglePlacesAPI

// Appearance: light ony # in Info.plist

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        GMSPlacesClient.provideAPIKey("AIzaSyAsFecW1SSVh-3c91LA60y9ZZA7Dh0w9zA")
        GooglePlaces.provide(apiKey: "AIzaSyAsFecW1SSVh-3c91LA60y9ZZA7Dh0w9zA")

        return true
    }
}


@main
struct TravelSpyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let persistenceController = PersistenceController.shared
    @StateObject var sessionStore = SessionStore.shared
    @StateObject var viewRouter = ViewRouter()
    @StateObject var userPostsModel = UserPostsModel()
    @StateObject var postsModel = PostsModel()
    @StateObject var viewAlertModel = AlertViewModel()
    
    init() {
        FirebaseApp.configure()
        UserDefaults.standard.set(["en_US"], forKey: "AppleLanguages")
    }
    
    var body: some Scene {        
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(sessionStore)
                .environmentObject(viewRouter)
                .environmentObject(postsModel)
                .environmentObject(userPostsModel)
                .environmentObject(viewAlertModel)
                .toast(isPresenting: $viewAlertModel.show, duration: 0.0, tapToDismiss: true) {
                    viewAlertModel.alertToast
                }
        }
    }
}
