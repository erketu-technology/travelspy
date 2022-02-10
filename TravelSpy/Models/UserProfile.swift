//
//  UserProfile.swift
//  TravelSpy
//
//  Created by AlexK on 26/01/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct UserProfile: Codable {
    var uid: String
    var userName: String
    var gogoleUserId: String?
    var email: String
    var avatar: String?
    var usersFollowing: [String] = []
    var usersFollowers: [String] = []
    var locationsFollowing: [String] = []

    static func template() -> UserProfile {
        return self.init(
            uid: "123",
            userName: "uerName",
            email: "test@example.com"
        )
    }
}
