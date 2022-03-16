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

struct Post: Identifiable, Equatable{
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }

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
                ["croppedUrl": "https://firebasestorage.googleapis.com:443/v0/b/travelspy-57015.appspot.com/o/images%2Fed7nGsphhBby45pDzO4Sa3X3Odt1%2FAAFCA652-AA10-4BF8-B9A3-A72CB356A784.png?alt=media&token=41cf9716-9660-42b1-a63f-3015398777e0"]
            ],
            user: UserProfile(uid: "123", userName: "username", email: "example@com")
        )
    }
}
