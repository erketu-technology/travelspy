//
//  LocalSearchViewData.swift
//  TravelSpy
//
//  Created by AlexK on 01/12/2021.
//

import MapKit

struct Location: Identifiable {
    var id = UUID()
    var city: String = ""
    var country: String = ""
    var latitude: Double?
    var longitude: Double?
    
    var countryAndCity: String {
        return [country, city].filter({ !$0.isEmpty }).joined(separator: ", ")
    }
}
