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
    var uid: String
    var createdAt: Date
    var updatedAt: Date
//    var location: GeoPoint
    var images: [
        Dictionary<String, String?>
    ]
    var state: PostState = .active
    
    var imageUrl: String? {
        return self.images.first?["croppedUrl"] ?? nil
    }
}
