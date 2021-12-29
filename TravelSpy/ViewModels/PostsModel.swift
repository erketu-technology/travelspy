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
    var document: DocumentSnapshot?
    var post: Post?
}

struct FirstItem {
    var document: DocumentSnapshot?
    var post: Post?
}

enum PostsModelError: Error {
    case notUserFound
}

class PostsModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var isFetching = false
    @Published var totalCount = 0
    
    var progressBarValue = ProgressBarValue()
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var lastItem = LastItem()
    var firstItem = FirstItem()
    var listener: ListenerRegistration?
    
    private var profileRepository = UserProfileRepository()
    
    func realTimeFetch() {
        guard listener == nil else { return }
        
        listener = db.collection("posts").whereField("state", isEqualTo: "active")
            .order(by: "createdAt", descending: true).addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                documents.forEach { document in
//                    Task {
//                        let post = await self.createPostRecord(document: document)
//                        if post != nil {
//                            self.posts.append(post!)
//                        }
//                    }
                }
            }
    }
    
    func detachListener() {
        if listener != nil {
            listener!.remove()
        }
    }
    
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
    
    @MainActor
    func fetchPosts(limit: Int = 3) async {
        guard !isFetching && posts.isEmpty else { return }
        
        let snapshot = try? await postsDB().limit(to: limit).getDocuments()
        guard let snapshot = snapshot else {
            isFetching = false
            return
        }
        
        for document in snapshot.documents {
            let post = await createPostRecord(document: document)
            guard let post = post else { continue }
            posts.append(post)
        }
        
        isFetching = false
        firstItem.post = posts.first
        firstItem.document = snapshot.documents.first
        
        lastItem.post = posts.last
        lastItem.document = snapshot.documents.last
    }
   
    @MainActor
    func fetchNextPosts() async {
        guard !isFetching && posts.count > 0 && firstItem.document != nil else { return }
        
        isFetching = true
        
        let snapshot = try? await postsDB().end(beforeDocument: firstItem.document!).getDocuments()
        guard let snapshot = snapshot else {
            isFetching = false
            return
        }
        
        if let doc = snapshot.documents.first {
            firstItem.document = doc
        }
        
        for document in snapshot.documents {
            let post = await createPostRecord(document: document)
            guard let post = post else { continue }
            posts.insert(post, at: 0)
        }
        
        firstItem.post = posts.first
        isFetching = false
    }
    
    @MainActor
    func fetchPreviousPosts(limit: Int = 3) async {
        guard !isFetching && posts.count > 0 && lastItem.document != nil else { return }
        
        isFetching = true
        
        let snapshot = try? await postsDB().start(afterDocument: lastItem.document!).limit(to: limit).getDocuments()
        guard let snapshot = snapshot else {
            isFetching = false
            return
        }
        
        if let doc = snapshot.documents.last {
            lastItem.document = doc
        }
        
        if (posts.last != nil) && posts.last!.uid.isEmpty {
            posts.removeLast(1)
        }
        
        for document in snapshot.documents {
            let post = await createPostRecord(document: document)
            guard let post = post else { continue }
            
            lastItem.post = post
            posts.append(post)
        }
        
        isFetching = false
        
        if totalCount > posts.count {
            let templatePost = Post.template()
            posts.append(templatePost)
        }
    }
    
    func fetchTotalCount() {
        guard totalCount == 0 else {
            return
        }
        
        db.collection("posts").whereField("state", isEqualTo: "active").getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            self.totalCount = snapshot.documents.count
        }
    }
    
    func isLastPost(_ post: Post) -> Bool {
        guard totalCount > posts.count else { return false }
        guard lastItem.post != nil else { return true }
        return lastItem.post?.id == post.id
    }
    
    private func postsDB() -> Query {
        return db.collection("posts").whereField("state", isEqualTo: "active").order(by: "createdAt", descending: true)
    }
    
    private func createPostRecord(document: QueryDocumentSnapshot) async -> Post? {
        let data = document.data()
        let createdAtTimestamp = data["createdAt"] as! Timestamp
        let updatedAtTimestamp = data["updatedAt"] as! Timestamp
        
        let uid = data["uid"] as! String
        let profile = await profileRepository.fetchProfile(userId: uid)
        guard let profile = profile else { return nil }
                
        
        let post = Post(
            id: document.documentID,
            content: data["content"] as! String,
            locationCity: data["locationCity"] as! String,
            locationCountry: data["locationCountry"] as! String,
            placemark: data["location"] as! GeoPoint,
            uid: uid,
            createdAt: createdAtTimestamp.dateValue(),
            updatedAt: updatedAtTimestamp.dateValue(),
            images: data["images"] as! [Dictionary<String, String?>],
            user: profile
        )
        
        return post
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


