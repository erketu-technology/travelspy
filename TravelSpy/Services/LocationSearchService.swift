//
//  LocationSearchService.swift
//  TravelSpy
//
//  Created by AlexK on 01/12/2021.
//

import Foundation
import MapKit
import Combine

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    var completer: MKLocalSearchCompleter
    @Published var completions: [MKLocalSearchCompletion] = []
    var cancellable: AnyCancellable?    

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        cancellable = $searchQuery.assign(to: \.queryFragment, on: self.completer)
        completer.delegate = self        
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
    
    func getLocationObject(for completion: MKLocalSearchCompletion, completionBlock: @escaping (Location) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
                
        var locationItem = Location()
        
        search.start { (response, error) in
            if (response?.mapItems[0] != nil) {
                let mapItem = (response?.mapItems[0])!
                
                
                locationItem.city = mapItem.name ?? ""                
                locationItem.country = mapItem.placemark.country ?? ""
                locationItem.latitude = mapItem.placemark.coordinate.latitude
                locationItem.longitude = mapItem.placemark.coordinate.longitude
            }
            completionBlock(locationItem)
        }
    }
}

extension MKLocalSearchCompletion: Identifiable {}
