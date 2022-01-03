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
        userName = profile?.userName ?? ""
    }
    
    var body: some View {
        VStack {
            List {
                Section("Account") {
                    NavigationLink {
                        ChangeUsernameView(userName: userName)
                    } label: {
                        Text("Username")
                    }
                }
                
                Section("Security") {
                    NavigationLink {
                        ChangePasswordView()
                    } label: {
                        Text("Password")
                    }
                }
                
                Section {
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
                                self.signOut()
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
    
    func signOut() {
        sessionStore.signOut()
        sessionStore.state = .signedOut
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = UserProfile(uid: "\(UUID())", userName: "userName", email: "example@com")
        PreferencesView(profile: profile)
    }
}
