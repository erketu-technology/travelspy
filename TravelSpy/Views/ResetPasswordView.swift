//
//  ForgotPasswordView.swift
//  TravelSpy
//
//  Created by AlexK on 30/12/2021.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var sessionStore: SessionStore
    @State private var email = ""
    @State private var alertMessage = ""
    @State var showAlert = false
    @State var dismissView = false
    @State var isLoading = false
    
    
    var disableForm: Bool {
        return email.isEmpty
    }
    
    var body: some View {
        VStack {
            TSTextField("Email", text: $email)
            
            Button(action: { self.resetPassword() }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        disableForm ? Color.gray : Color(red: 0.331, green: 0.184, blue: 0.457)
                    )
                    .cornerRadius(12)
            }
            .disabled(disableForm)
            
            Spacer()
        }
        .overlay(ProgressView()
                    .padding(.all, 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .opacity(isLoading ? 1 : 0))
        .padding()
        .padding(.top, 30)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Reset password")
        .alert(isPresented: $showAlert, content: {
            Alert(
                title: Text("Reset password"),
                message: Text(alertMessage),
                dismissButton: .default(Text("Okay"), action: {
                    if dismissView {
                        self.presentation.wrappedValue.dismiss()
                    }
                })
            )
        })
    }
    
    func resetPassword() {
        dismissView = false
        isLoading = true
        
        sessionStore.resetPassword(email: email) { error in
            isLoading = false
            showAlert = true
            if error != nil {
                alertMessage = error!.localizedDescription
            } else {
                dismissView = true
                alertMessage = "Please check your email to continue"
            }
        }
    }
    
    struct ForgotPasswordView_Previews: PreviewProvider {
        static var previews: some View {
            ResetPasswordView()
        }
    }
}
