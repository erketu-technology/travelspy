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
    @AppStorage("login") private var login = false
    let publicDatabase = CKContainer(identifier: "iCloud.com.erketutech.travelspy").publicCloudDatabase
    
    @State var userName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    @State var showSignUpForm = false
//    @State var isShowConfirmEmail = false
    
//    @State var showDetails = false
    @State var isLoading = false
    
    @EnvironmentObject var sessionStore: SessionStore
//    @State var profile: UserProfile?
    
//    let userID = UserDefaults.standard.object(forKey: "userID") as? String
    
    var body: some View {
        VStack {
            if showSignUpForm {
                Form {
                    Section {
                        TextField("username", text: $userName)
                            .textContentType(.username)
                            .autocapitalization(.none)
                    }
                    Section {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
//                        SecureField("Confirm password", text: $confirmPassword)
//                            .autocapitalization(.none)
                    }
                    Button(action: { self.signUp() }) {
                        Text("Sign up")
                    }
                }
            } else {
                VStack {
                    Image(systemName: "person")
                    
//                    if isShowConfirmEmail {
//                        Text("Please confirm your email")
//                    }
                    
                    Form {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                        Button(action: { self.signIn() }) {
                            Text("Sign in")
                        }
                    }
                }
            }
            Button("Sign in with Google") {
                self.googleSignIn()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemIndigo))
            .cornerRadius(12)
            .padding()
            Button(action: { self.showSignUpForm.toggle() }) {
                Text(self.showSignUpForm ? "Have an account? Sign in instead." : "No account yet? Click here to sign up instead.")
            }
        }
        .disabled(isLoading)
        .overlay(ProgressView()
                    .padding(.all, 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .opacity(isLoading ? 1 : 0))
    }
    
    func signUp() {
        sessionStore.signUp(email: self.email, password: self.password, userName: self.userName) { (profile, error) in
            isLoading = false
            
            if let error = error {
                print("Error when signing up: \(error)")
                return
            }
//            self.profile = profile
//            self.showDetails.toggle()
            
//            self.isShowConfirmEmail = true
            self.showSignUpForm = false
        }
    }
    
    func signIn() {
        isLoading = true
        sessionStore.signIn(email: self.email, password: self.password) { (profile, error) in
            isLoading = false
            
            if let error = error {
                print("Error when signing up: \(error)")
                return
            }
//            self.profile = profile
//            self.showDetails.toggle()
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
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
