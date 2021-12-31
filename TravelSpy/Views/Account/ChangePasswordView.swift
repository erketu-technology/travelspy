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
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State var isLoading = false
    @State var errorMessage = ""
    
    var body: some View {
        ActivityIndicator(isShowing: $isLoading) {
            VStack {
                Section {
                    TSSecureField("current password", text: $currentPassword)
                }
                .padding(.bottom, 20)
                
                Section {
                    TSSecureField("new password", text: $newPassword)
                    TSSecureField("confirm password", text: $confirmPassword)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(Color.red)
                        .font(.system(size: 13))
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
    }
    
    private func changePassword() {
        isLoading = true
        errorMessage = ""
        sessionStore.changePassword(currentPassword: currentPassword, newPassword: newPassword) { error in

            isLoading = false
            if error != nil {
                errorMessage = error!.localizedDescription
                return
            }
            self.presentation.wrappedValue.dismiss()
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
