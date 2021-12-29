//
//  UserProfileRepository.swift
//  TravelSpy
//
//  Created by AlexK on 14/12/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct UserProfile: Codable {
    var uid: String
    var userName: String
    var gogoleUserId: String?
    var email: String
}

class UserProfileRepository: ObservableObject {
    private var db = Firestore.firestore()
    
    func createProfile(profile: UserProfile, completion: @escaping (_ profile: UserProfile?, _ error: Error?) -> Void) {
        do {
            let _ = try db.collection("users").document(profile.uid).setData(from: profile)
            completion(profile, nil)
        }
        catch let error {
            print("Error writing city to Firestore: \(error)")
            completion(nil, error)
        }
    }
    
    func fetchProfile(userId: String, completion: @escaping (_ profile: UserProfile?, _ error: Error?) -> Void) {
        db.collection("users").document(userId).getDocument { (snapshot, error) in
            let profile = try? snapshot?.data(as: UserProfile.self)
            completion(profile, error)
        }
    }
    
    func fetchProfile(userId: String) async -> UserProfile? {
        let profile = try? await db.collection("users").document(userId).getDocument()
        return try? profile?.data(as: UserProfile.self)
    }
}
