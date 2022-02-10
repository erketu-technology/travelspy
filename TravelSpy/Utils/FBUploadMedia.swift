//
//  FBUploadMedia.swift
//  TravelSpy
//
//  Created by AlexK on 03/02/2022.
//

import Foundation
import Firebase
import UIKit

class FBUploadMedia {
    let user: User
    let path: String // = "images/\(currentUser.uid)"

    init(path: String?, user: User) {
        self.path = path ?? "images/\(user.uid)"
        self.user = user
    }

    func upload(image: UIImage, completion: @escaping ((_ url: URL?, _ error: Error?) -> ())) -> StorageUploadTask {
        let storageRef = Storage.storage().reference().child("\(path)/\(UUID()).png")
        let imgData = image.pngData()

        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        let task = storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            if error == nil {
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url, error)
                })
            } else {
                print("error in save image \(String(describing: error?.localizedDescription))")
                completion(nil, error)
            }
        }

        return task
    }
}
