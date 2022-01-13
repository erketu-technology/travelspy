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
        
        search.start { (response, error) in
            if (response?.mapItems[0] != nil) {
                let mapItem = (response?.mapItems[0])!
                
                let locationItem = Location(city: mapItem.name ?? "",
                                            country: mapItem.placemark.country ?? "",
                                            latitude: mapItem.placemark.coordinate.latitude,
                                            longitude: mapItem.placemark.coordinate.longitude)
                completionBlock(locationItem)
            }
        }
    }
}

extension MKLocalSearchCompletion: Identifiable {}
