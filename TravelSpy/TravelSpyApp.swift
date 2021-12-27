//
//  TravelSpyApp.swift
//  TravelSpy
//
//  Created by AlexK on 25/11/2021.
//

import SwiftUI
import Firebase

@main
struct TravelSpyApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var sessionStore = SessionStore()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {        
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(sessionStore)
        }
    }
}
