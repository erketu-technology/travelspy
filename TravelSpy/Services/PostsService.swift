//
//  PostsService.swift
//  TravelSpy
//
//  Created by AlexK on 08/12/2021.
//

import Foundation
import CoreData
import CloudKit
import SwiftUI

class PostsService: NSObject {
    static let publicDatabase = CKContainer(identifier: "iCloud.com.erketutech.travelspy").publicCloudDatabase
    static var cursor: CKQueryOperation.Cursor?
    
    static func fetchPosts(_ posts: Binding<[Post]>) {
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "content", ascending: false)   
        
        let query = CKQuery(recordType: "Posts", predicate: pred)
        query.sortDescriptors = [sort]
        
        var operation: CKQueryOperation
                
        if (cursor == nil) {
            operation = CKQueryOperation(query: query)
        } else {
            operation = CKQueryOperation(cursor: cursor!)
        }
        
//        operation.desiredKeys = ["id","name", "content"]
        operation.resultsLimit = 5
        
        operation.recordMatchedBlock = { (recordId, result) in
            switch result {
            case .success(let record):
                if let images = record["images"] as? Array<CKAsset> {
                    print("ASSETS \(images)")
                }
                var post = Post()
                post.content = record["content"]
                
                posts.wrappedValue.append(post)
                
                
            case .failure(let error):
                print("EEEEEEEE \(error.localizedDescription)")
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                self.cursor = cursor
            case .failure(let error):
                print("EEEEEEEE \(error.localizedDescription)")
            }
        }
        
        publicDatabase.add(operation)
    }
    
    static func delete() {
        let recordId = CKRecord.ID(recordName: "9E807A03-89A2-49B7-A2F0-C0ED177EEA64")
        publicDatabase.delete(withRecordID: recordId) { (recordId, err) in
            if let err = err {
                print("#### Error: \(err.localizedDescription)")
            }
        }
    }    
}
