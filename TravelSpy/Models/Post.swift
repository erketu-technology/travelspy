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
                ["croppedUrl": "https://firebasestorage.googleapis.com:443/v0/b/travelspy-57015.appspot.com/o/images%2FPhTFkKvrhQUfEK69wKke2eIHBkH2%2F7373EB9A-5D2A-480A-9640-E7AC8216BEFC.png?alt=media&token=994d8645-8b54-4144-b51e-39c0701d735f"]
            ],
            user: UserProfile(uid: "123", userName: "username", email: "example@com")
        )
    }
}
