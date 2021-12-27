//
//  PostsModel.swift
//  TravelSpy
//
//  Created by AlexK on 10/12/2021.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import SwiftUI

struct UploadedUrls {
    var croppedUrl: String?
    var originalUrl: String?
}

struct ProgressBarValue {
    var croppedImageUpload: Double = 0.0
    var originalImageUpload: Double = 0.0
    var postUpload: Double = 0.0
}

struct LastItem {
    var docuemnt: DocumentSnapshot?
    var post: Post?
}

enum PostsModelError: Error {
    case notUserFound
}

class PostsModel: ObservableObject {
    var progressBarValue = ProgressBarValue()
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var totalCount = 0
    var posts: [Post] = []
    var lastCurrentPageDoc =  LastItem()
    @Published var isFetching = false
    
    func addPost(content: String, locationItem: Location, selectedPhoto: Photo,
                 progressBlock: @escaping (ProgressBarValue) -> Void, onComplete: @escaping (Error?) -> ()) {
        
        guard let currentUser = Auth.auth().currentUser else { return onComplete(PostsModelError.notUserFound) }
        
        startUploading(image: selectedPhoto, updateProgressBlock: {
            progressBlock(self.progressBarValue)
        }, completion: { uploadedUrls, error in
            guard let uploadedUrls = uploadedUrls else { return onComplete(error) }
            if error != nil {
                onComplete(error)
                return
            }
            
            self.db.collection("posts").addDocument(data: [
                "content": content,
                "uid": currentUser.uid,
                "images": [
                    ["croppedUrl": uploadedUrls.croppedUrl]
                ],
                "location": GeoPoint(latitude: locationItem.latitude!, longitude: locationItem.longitude!),
                "locationCity": locationItem.city,
                "locationCountry": locationItem.country,
                "createdAt": Date(),
                "updatedAt": Date(),
                "state": "active"
            ], completion: { error in
                print("NO ERRORS")
                if error != nil {
                    onComplete(error)
                    print("error in save image \(String(describing: error?.localizedDescription)))")
                }
                
                self.progressBarValue.postUpload = 1
                progressBlock(self.progressBarValue)
                onComplete(nil)
            })
        })
    }
    
    func deletePost(post: Post) {
        // delete
    }
    
    func refreshAll(completion: @escaping ([Post]) -> ()) {
        self.lastCurrentPageDoc = LastItem()
        self.posts.removeAll()
        
        fetch { posts in
            completion(posts)
        }
    }
    
    func fetch(completion: @escaping ([Post]) -> ()) {
        guard !isFetching && (self.totalCount == 0 || self.totalCount > self.posts.count) else { return }
        
        isFetching = true
        self.fetchTotalCount { totalCount, error in
            guard error == nil else {
                self.isFetching = false
                print("Error when get total count: \(String(describing: error?.localizedDescription))")
                return
            }
            
            self.totalCount = totalCount!
            
            self.fetchPosts { snapshot, error in
                if error != nil {
                    self.isFetching = false
                    print("###ERROR getPosts: \(String(describing: error?.localizedDescription))")
                }
                
                guard let snapshot = snapshot else {
                    self.isFetching = false
                    return
                }
                
                self.lastCurrentPageDoc.docuemnt = snapshot.documents.last
                
                if self.posts.last != nil && self.posts.last!.content.isEmpty {
                    self.posts.removeLast()
                }
                snapshot.documents.forEach { document in
                    let data = document.data()
                    
                    let createdAtTimestamp = data["createdAt"] as! Timestamp
                    let updatedAtTimestamp = data["updatedAt"] as! Timestamp
                    
                    let post = Post(
                        id: document.documentID,
                        content: data["content"] as! String,
                        locationCity: data["locationCity"] as! String,
                        locationCountry: data["locationCountry"] as! String,
                        uid: data["uid"] as! String,
                        createdAt: createdAtTimestamp.dateValue(),
                        updatedAt: updatedAtTimestamp.dateValue(),
                        images: data["images"] as! [Dictionary<String, String?>]
                    )
                    
                    self.posts.append(post)
                }
                
                self.lastCurrentPageDoc.post = self.posts.last
                self.isFetching = false
                
                let shimmerPost = Post(
                    content: "", locationCity: "",
                    locationCountry: "", uid: "",
                    createdAt: Date(), updatedAt: Date(),
                    images: []
                )
                self.posts.append(shimmerPost)
                completion(self.posts)
            }
        }
    }
    
    func isLastPost(_ post: Post) -> Bool {
        guard lastCurrentPageDoc.post != nil else { return true }
        return lastCurrentPageDoc.post?.id == post.id
    }
    
    private func fetchPosts(completion: @escaping (QuerySnapshot?, Error?) -> ()) {
        var query = db.collection("posts").whereField("state", isEqualTo: "active")
            .order(by: "createdAt", descending: true).limit(to: 3)
        
        if self.posts.count > 0 && lastCurrentPageDoc.docuemnt != nil {
            query = query.start(afterDocument: lastCurrentPageDoc.docuemnt!)
        }
        
        query.getDocuments { snapshot, error in
            completion(snapshot, error)
        }
    }
    
    private func fetchTotalCount(completion: @escaping (Int?, Error?) -> ()) {
        guard totalCount == 0 else {
            completion(totalCount, nil)
            return
        }
        
        db.collection("posts").whereField("state", isEqualTo: "active").getDocuments{ snapshot, error in
            guard let snapshot = snapshot else { return }
            
            let count = snapshot.documents.count
            completion(count, nil)
        }
    }
    
    private func startUploading(image: Photo, updateProgressBlock: @escaping () -> (), completion: @escaping (UploadedUrls?, Error?) -> ()) {
        var uploadedUrls = UploadedUrls()
        
        uploadMedia(image: image.cropped) { url, error in
            if error != nil {
                completion(nil, error)
                return
            }
            
            uploadedUrls.croppedUrl = url?.absoluteString
            
            completion(uploadedUrls, nil)
            // Try to upload in Background origal image
            //            let task = self.uploadMedia(image: image.original) { url, error in
            //                if error != nil {
            //                    completion(nil, error)
            //                    return
            //                }
            //                print("ORIGINAL URL \(url?.absoluteString)")
            //                uploadedUrls.originalUrl = url?.absoluteString
            //                completion(uploadedUrls, nil)
            //                print("ORIGINAL 2 URL \(uploadedUrls.originalUrl)")
            //            }
            //
            //            task.observe(.progress) { snapshot in
            //                let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            //                self.progressBarValue.originalImageUpload = percentComplete
            //                updateProgressBlock()
            //                print("PROGRESS ORIGINAL \(percentComplete)")
            //            }
            
            //            task.observe(.success) { snapshot in
            //                print("SUCCESS")
            //
            //                completion(uploadedUrls, nil)
            //            }
        }.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            self.progressBarValue.croppedImageUpload = percentComplete
            updateProgressBlock()
            print("PROGRESS  CROPPPED \(percentComplete)")
        }
    }
    
    private func uploadMedia(image: UIImage, completion: @escaping ((_ url: URL?, _ error: Error?) -> ())) -> StorageUploadTask {
        let storageRef = Storage.storage().reference().child("images/\(currentUser!.uid)/\(UUID()).png")
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


