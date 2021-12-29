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


// If we don't use cache need to use `:Codable` +
// fix document.data(as: Post.self) in PostsModel

struct Post: Identifiable {
    enum PostState {
        case active
        case draft
    }
    
    @DocumentID var id: String?
    var content: String
    var locationCity: String
    var locationCountry: String
    var placemark: GeoPoint
    var uid: String
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
        return [locationCountry, locationCity].filter({ !$0.isEmpty }).joined(separator: ", ")
    }
    
    static func template(content: String = "content") -> Post {
        return self.init(
            content: content,
            locationCity: "London",
            locationCountry: "United Kingdom",
            placemark: GeoPoint(latitude: 51.5072, longitude: 0.1276),
            uid: "",
            createdAt: Date(),
            updatedAt: Date(),
            images: [
                ["croppedUrl": "https://firebasestorage.googleapis.com:443/v0/b/travelspy-57015.appspot.com/o/images%2FPhTFkKvrhQUfEK69wKke2eIHBkH2%2F7373EB9A-5D2A-480A-9640-E7AC8216BEFC.png?alt=media&token=994d8645-8b54-4144-b51e-39c0701d735f"]
            ],
            user: UserProfile(uid: "123", userName: "username", email: "example@com")
        )
    }
}
