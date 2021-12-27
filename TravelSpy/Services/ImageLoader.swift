//
//  ImageLoader.swift
//  TravelSpy
//
//  Created by AlexK on 24/12/2021.
//

import Foundation
import UIKit

class ImageLoader: ObservableObject {
    let url: String?
    @Published var image: UIImage? = nil
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(url: String?) {
        self.url = url
    }
    
    func fetch() {
        guard image == nil && !isLoading else { return }
        
        guard let url = url, let fetchURL = URL(string: url) else {
            errorMessage = "Bad URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = URLRequest(url: fetchURL, cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: 60 * 60 * 24 * 3) // 3 days
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                    self.errorMessage = "Bad Response: \(response.statusCode)"
                } else  if let data = data, let image = UIImage(data: data) {
                    self.image = image
                } else {
                    self.errorMessage = "Unknown error"
                }
            }
            
        }
        
        task.resume()        
    }
}
