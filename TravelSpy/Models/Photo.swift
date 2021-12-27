//
//  photo.swift
//  TravelSpy
//
//  Created by AlexK on 02/12/2021.
//

import Foundation
import UIKit
import Photos
import MapKit

struct Photo: Identifiable {
    var id = UUID()
    var original = UIImage()
    var cropped = UIImage()
    var asset: PHAsset?
    
    func getLocation(completion: @escaping (_ location: Location) -> Void) {
        let latitude = asset?.location?.coordinate.latitude ?? 0.0
        let longitude = asset?.location?.coordinate.longitude ?? 0.0
        
        let geoCoder = CLGeocoder()
                
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            // Place details
            guard let placeMark = placemarks?.first else { return }
                        
            let country = placeMark.country ?? ""
            let city = placeMark.locality ?? ""
            
            let location = Location(city: city, country: country, latitude: latitude, longitude: longitude)
                        
            completion(location)
        }
    }
}
