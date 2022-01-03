//
//  ChangeUsernameView.swift
//  TravelSpy
//
//  Created by AlexK on 31/12/2021.
//

import SwiftUI

struct ChangeUsernameView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var viewAlertModel: AlertViewModel
        
    @State var userName: String
    
    var body: some View {
        VStack {
            TSTextField("username", text: $userName)
            Spacer()
        }
        .padding()
        .padding(.top, 30)
        .navigationTitle("Change username")
        .navigationBarItems(
            trailing: (
                Button(action: {
                    changeUsername()
                }, label: {
                    Text("Save")
                })
                    .disabled(userName.isEmpty)
            )
        )
    }
    
    private func changeUsername() {
        sessionStore.changeUsername(userName: userName) { error in
            if error != nil {
                self.viewAlertModel.setAlert(status: .error, title: "Username: \(error!.localizedDescription)")
            } else {
                self.viewAlertModel.setAlert(status: .success, title: "Username has been changed.")
            }
        }
        presentation.wrappedValue.dismiss()
    }
}

struct ChangeUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeUsernameView(userName: "")
    }
}
