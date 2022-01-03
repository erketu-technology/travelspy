//
//  ChangePasswordView.swift
//  TravelSpy
//
//  Created by AlexK on 30/12/2021.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var viewAlertModel: AlertViewModel
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack {
            Section {
                TSSecureField("current password", text: $currentPassword)
            }
            .padding(.bottom, 20)

            Section {
                TSSecureField("new password", text: $newPassword)
                TSSecureField("confirm password", text: $confirmPassword)
            }

            Spacer()
        }
        .padding()
        .padding(.top, 30)
        .navigationTitle("Change password")
        .navigationBarItems(
            trailing: (
                Button(action: {
                    changePassword()
                }, label: {
                    Text("Save")
                })
                    .disabled(
                        currentPassword.isEmpty ||
                        newPassword.isEmpty ||
                        newPassword != confirmPassword
                    )
            )
        )
    }
    
    private func changePassword() {
        sessionStore.changePassword(currentPassword: currentPassword, newPassword: newPassword) { error in
            
            if error != nil {
                self.viewAlertModel.setAlert(status: .error, title: "Password: \(error!.localizedDescription)")
            } else {                
                self.presentation.wrappedValue.dismiss()
                self.viewAlertModel.setAlert(status: .success, title: "Password has been changed.")
            }
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
