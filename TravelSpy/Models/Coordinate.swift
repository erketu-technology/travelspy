//
//  Coordinate.swift
//  TravelSpy
//
//  Created by AlexK on 10/12/2021.
//

import Foundation
import MapKit

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double

    func locationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude,
                                      longitude: self.longitude)
    }
}
