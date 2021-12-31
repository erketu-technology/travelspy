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
        VStack {
            TSSecureField("current password", text: $currentPassword)
            Spacer()
                        
            Section {
                SecureField("current password", text: $currentPassword)
            }
            Divider()
                .padding(.bottom, 20)
            Section {
                SecureField("new password", text: $newPassword)
                Divider()
                SecureField("confirm password", text: $confirmPassword)
                Divider()
            }
            
            Text(errorMessage)
                .foregroundColor(Color.red)
                .font(.system(size: 13))
            
            Spacer()
        }
        .padding()
        .disabled(isLoading)
        .overlay(ProgressView()
                    .padding(.all, 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .opacity(isLoading ? 1 : 0))
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
