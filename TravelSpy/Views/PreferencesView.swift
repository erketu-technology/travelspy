//
//  PreferencesView.swift
//  TravelSpy
//
//  Created by AlexK on 26/12/2021.
//

import SwiftUI

struct PreferencesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sessionStore: SessionStore
    @State private var userName: String    
    
    init(profile: UserProfile?) {
        _userName = State(wrappedValue: profile?.userName ?? "")
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("username", text: $userName)
            }
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = UserProfile(uid: "\(UUID())", userName: "userName")
        PreferencesView(profile: profile)
    }
}
