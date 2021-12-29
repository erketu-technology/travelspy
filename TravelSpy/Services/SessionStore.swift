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

class SessionStore: NSObject, ObservableObject {
    
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = Auth.auth().currentUser != nil ? .signedIn : .signedOut
    @Published var profile: UserProfile?
    
    private var profileRepository = UserProfileRepository()
    
//    override init() {
//        super.init()
//        print("AUTHHHH INIT")
//        self.fetchProfile()
//    }
    
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
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            self.profile = nil
            
            state = .signedOut
        }
        catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}
