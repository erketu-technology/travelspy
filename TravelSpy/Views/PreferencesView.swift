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
    @State private var showingLogOutAlert = false
    
    private let userName: String
    
    init(profile: UserProfile?) {
//        _userName = State(wrappedValue: profile?.userName ?? "")
        userName = profile?.userName ?? ""
    }
    
    var body: some View {
        VStack {
            List {
                Section("Security") {
                    Button {
                        print("Password")
                    } label: {
                        Text("Password")
                            .foregroundColor(Color.primary)
                    }
                }
                
                Section("Account") {
                    Button {
                        showingLogOutAlert = true
                    } label: {
                        Text("Log out")
                            .foregroundColor(Color.red)
                    }
                    .alert(isPresented: $showingLogOutAlert) {
                        Alert(
                            title: Text("Are you sure you want to log out?"),
                            primaryButton: .destructive(Text("Log Out")) {
                                sessionStore.signOut()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(userName)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = UserProfile(uid: "\(UUID())", userName: "userName", email: "example@com")
        PreferencesView(profile: profile)
    }
}
