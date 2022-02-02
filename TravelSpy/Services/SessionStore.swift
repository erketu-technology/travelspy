//
//  SessionStore.swift
//  TravelSpy
//
//  Created by AlexK on 14/12/2021.
//

import Foundation
import Combine
import Firebase
import GoogleSignIn

enum SessionError: String, Error {
    case userNotFound = "user is not found"
}

class SessionStore: NSObject, ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }

    enum LocationAction {
        case follow
        case unfollow
    }
    
    @Published var state: SignInState = Auth.auth().currentUser != nil ? .signedIn : .signedOut
    @Published var profile: UserProfile?

    private var profileRepository = UserProfileRepository()

    static let shared = SessionStore()
    
    func signUp(email: String, password: String, userName: String, completion: @escaping (_ profile: UserProfile?, _ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error signing up: \(error)")
                completion(nil, error)
                return
            }

            guard let user = result?.user else { return }
            print("User \(user.uid) signed up.")
            
            //            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
            //                print("sendEmailVerification \(String(describing: error?.localizedDescription))")
            //            })
            //            signOut()
            let userProfile = UserProfile(uid: user.uid, userName: userName, email: email)

            self.profileRepository.createProfile(profile: userProfile) { (profile, error) in
                if let error = error {
                    print("Error while fetching the user profile: \(error)")
                    completion(nil, error)
                    return
                }
                self.profile = profile
                self.state = .signedIn
                completion(profile, nil)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (_ profile: UserProfile?, _ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error signing in: \(error)")
                completion(nil, error)
                return
            }
            
            guard let user = result?.user else { return }
            
            print("User \(user.uid) signed in.")
            //            if !user.isEmailVerified {
            //                completion(nil, error)
            //                return
            //            }
            
            self.fetchProfile() { profile, error in
                self.state = .signedIn
                completion(profile, nil)
            }
        }
    }
    
    func fetchProfile(completion: @escaping (_ profile: UserProfile?, _ error: Error?) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        
        self.profileRepository.fetchProfile(userId: user.uid) { (profile, error) in
            if let error = error {
                print("Error while fetching the user profile: \(error)")
                completion(nil, error)
                return
            }
            
            self.profile = profile
            completion(profile, nil)
        }
    }
    
    func googleSignIn(completion: @escaping (_ profile: UserProfile?, _ error: Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        guard let ctrl = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).last?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: ctrl) { user, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                guard let firUser = authResult?.user else { return }

                self.fetchProfile() { profile, error in
                    guard profile == nil else {
                        self.profile = profile
                        self.state = .signedIn
                        
                        completion(profile, nil)
                        return
                    }
                    
                    let userName = user?.profile?.name ?? ""
                    let userProfile = UserProfile(uid: firUser.uid, userName: userName, email: firUser.email!)
                    
                    self.profileRepository.createProfile(profile: userProfile) { (profile, error) in
                        if let error = error {
                            print("Error while fetching the user profile: \(error)")
                            completion(nil, error)
                            return
                        }
                        self.profile = profile
                        self.state = .signedIn
                        completion(profile, nil)
                    }
                }
            }
        }
    }
    
    @MainActor
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            self.profile = nil
        }
        catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(SessionError.userNotFound)
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                completion(error)
            }
            else {
                user.updatePassword(to: newPassword, completion: { (error) in
                    completion(error)
                })
            }
        })
    }
    
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    func changeUsername(userName: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        
        profileRepository.updateProfile(userId: user.uid, userName: userName) { error in
            if error != nil {
                print("### changeUsername: \(error!.localizedDescription)")
                completion(error)
            } else {
                self.profile?.userName = userName
                completion(nil)
            }
        }
    }

    func followLocation(_ location: Location, action: LocationAction) async {
        guard var userProfile = profile else { return }

        if action == .follow {
            userProfile.locationsFollowing.appendIfNotContains(location.key)
        } else {
            if let index = userProfile.locationsFollowing.firstIndex(of: location.key) {
                userProfile.locationsFollowing.remove(at: index)
            }
        }
        await profileRepository.updateProfile(profile: userProfile)
        profile = userProfile
        print("### update profiile")
    }
}
