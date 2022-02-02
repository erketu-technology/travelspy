//
//  FirPost.swift
//  TravelSpy
//
//  Created by AlexK on 11/12/2021.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct Post: Identifiable {
    enum PostState {
        case active
        case draft
    }
    
    @DocumentID var id: String?
    var uid: String
    var content: String
    var location: Location
    var createdAt: Date
    var updatedAt: Date
    var images: [
        Dictionary<String, String?>
    ]
    var state: PostState = .active
    var imageUrl: String? {
        return self.images.first?["croppedUrl"] ?? nil
    }
    var user: UserProfile
    var followersKey: [String] = []
    
    var countryAndCity: String {
        return location.countryAndCity
    }
    
    static func template(content: String = "content") -> Post {
        return self.init(
            uid: "",
            content: content,
            location: Location.template(),
            createdAt: Date(),
            updatedAt: Date(),
            images: [
                ["croppedUrl": "https://firebasestorage.googleapis.com/v0/b/travelspy-57015.appspot.com/o/images%2Fed7nGsphhBby45pDzO4Sa3X3Odt1%2FD3BEB946-5B24-4A11-9A77-0527D7666D9B.png?alt=media&token=dd374220-33f8-4508-a0df-3c700c7a2fa5"]
            ],
            user: UserProfile(uid: "123", userName: "username", email: "example@com")
        )
    }
}
