//
//  UsersModel.swift
//  TravelSpy
//
//  Created by AlexK on 15/01/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import SwiftUI

class UserPostsModel: PostsModel {
    let sessionStore = SessionStore.shared

    override func postsDB() -> Query {
        var followers = [sessionStore.profile!.uid]
        followers.append(contentsOf: sessionStore.profile!.usersFollowing)
        followers.append(contentsOf: sessionStore.profile!.locationsFollowing)
        
        return super.postsDB().whereField("followersKey", arrayContainsAny: followers)
    }
}

class CurrentUserPostsModel: PostsModel {
    let sessionStore = SessionStore.shared

    override func postsDB() -> Query {
        return super.postsDB().whereField("uid", isEqualTo: sessionStore.profile!.uid)
    }
}

class ExternalUserPostsModel: PostsModel {
    let uid: String

    init(uid: String) {
        self.uid = uid
    }

    override func postsDB() -> Query {
        return super.postsDB().whereField("uid", isEqualTo: uid)
    }
}
