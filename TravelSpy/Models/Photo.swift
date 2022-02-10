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
    
    func getLocation() async -> Location? {
        let latitude = asset?.location?.coordinate.latitude ?? 0.0
        let longitude = asset?.location?.coordinate.longitude ?? 0.0
        
        let geoCoder = CLGeocoder()
                
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let placemarks = try? await geoCoder.reverseGeocodeLocation(location)
        guard let placeMark = placemarks?.first else { return nil }

        let country = placeMark.country ?? ""
        let city = placeMark.locality ?? ""

        return Location(city: city, country: country, latitude: latitude, longitude: longitude)
    }

    static func template() -> Photo {
        return self.init(
            cropped: UIImage(systemName: "person")!
        )
    }
}
