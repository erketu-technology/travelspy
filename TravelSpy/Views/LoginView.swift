//
//  LoginView.swift
//  TravelSpy
//
//  Created by AlexK on 06/12/2021.
//

import SwiftUI
import AuthenticationServices
import CloudKit

import Firebase
import GoogleSignIn

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionStore: SessionStore
    
    @State var userName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var showSignUpForm = false
    @State var isLoading = false
    @State var showAlert = false
    @State var errorMsg = ""
    
    var disableSignUpForm: Bool {
        return userName.isEmpty || email.isEmpty || password.isEmpty
    }
    
    var disableSignInForm: Bool {
        return email.isEmpty || password.isEmpty
    }
    
    var body: some View {
        ActivityIndicator(isShowing: $isLoading) {
            ZStack {
                VStack {
                    VStack {
                        if showSignUpForm {
                            TSTextField("Username", text: $userName)
                                .textContentType(.username)
                                .padding(.bottom, 15)
                                .padding(.top, 10)
                            TSTextField("Email", text: $email)
                                .textContentType(.emailAddress)
                            TSSecureField("Password", text: $password)
                                .textContentType(.password)
                                .padding(.bottom, 15)

                            Button(action: { self.signUp() }) {
                                Text("Sign up")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        disableSignUpForm ? Color.gray : Color(red: 0.331, green: 0.184, blue: 0.457)
                                    )
                                    .cornerRadius(12)
                            }
                            .disabled(disableSignUpForm)
                        } else {
                            TSTextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .padding(.top, 10)
                            TSSecureField("Password", text: $password)
                                .textContentType(.password)

                            HStack {
                                Spacer()
                                NavigationLink {
                                    ResetPasswordView()
                                } label: {
                                    Text("forgot password")
                                }
                            }
                            .accentColor(.none)
                            .padding(.bottom, 20)


                            Button(action: { self.signIn() }) {
                                Text("Sign in")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        disableSignInForm ? Color.gray : Color(red: 0.331, green: 0.184, blue: 0.457)
                                    )
                                    .cornerRadius(12)

                            }
                            .disabled(disableSignInForm)
                        }
                        HStack {
                            VStack {
                                Divider()
                                    .background(Color.secondary)
                            }
                            .padding(20)

                            Text("or")
                                .foregroundColor(Color.secondary)
                            VStack {
                                Divider()
                                    .background(Color.secondary)
                            }
                            .padding(20)
                        }

                        Button(self.showSignUpForm ? "Sign up with Google" : "Sign in with Google") {
                            self.googleSignIn()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemIndigo))
                        .cornerRadius(12)
                        .padding(.horizontal, 10)

                        Button(action: { self.showSignUpForm.toggle() }) {
                            Text(self.showSignUpForm ? "Have an account? Sign in instead." : "No account yet? Click here to sign up instead.")
                        }
                        .accentColor(.none)
                        .padding()
                    }
                    .background(Color.white.opacity(0.7))
                    .shadow(color: Color.white, radius: 7)
                }
                .alert(isPresented: $showAlert, content: {
                    Alert(
                        title: Text("Error"),
                        message: Text(errorMsg),
                        dismissButton: .default(Text("Okay"))
                    )
                })
            }
            .padding(.horizontal, 10)
            .padding(.top, 20)
            .navigationTitle("TravelSpy")
        }
    }
    
    func signUp() {
        isLoading = true
        sessionStore.signUp(email: self.email, password: self.password, userName: self.userName) { (profile, error) in
            isLoading = false
            
            if let error = error {
                print("Error when sign up: \(error)")
                errorMsg = error.localizedDescription
                showAlert.toggle()
                
                return
            }
            //            self.isShowConfirmEmail = true
            self.showSignUpForm = false
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func signIn() {
        isLoading = true
        sessionStore.signIn(email: self.email, password: self.password) { (profile, error) in
            isLoading = false
            
            if let error = error {
                print("Error when sign in: \(error)")
                errorMsg = "Incorrect email or password"
                showAlert.toggle()
                
                return
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func googleSignIn() {
        isLoading = true
        sessionStore.googleSignIn { profile, error in
            isLoading = false
            if let error = error {
                print("Error when signing up: \(error)")
                return
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
