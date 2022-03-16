//
//  LocationPicker.swift
//  TravelSpy
//
//  Created by AlexK on 10/03/2022.
//

import Foundation
import UIKit
import SwiftUI
import GooglePlaces
import GooglePlacesAPI

struct PlacePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let completionBlock: (Location) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, completionBlock: completionBlock)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<PlacePicker>) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))
        autocompleteController.placeFields = fields

        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController.autocompleteFilter = filter
        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: UIViewControllerRepresentableContext<PlacePicker>) {
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate {
        var parent: PlacePicker
        var completionBlock: (Location) -> Void

        init(_ parent: PlacePicker, completionBlock: @escaping (Location) -> Void) {
            self.parent = parent
            self.completionBlock = completionBlock
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            guard let placeId = place.placeID else { return }
            
            GooglePlaces.placeDetails(forPlaceID: placeId, language: "en") { response, error in
                if error != nil {
                    print("### placeDetails: \(String(describing: error))")
                    return
                }

                guard let longitude = response?.result?.geometryLocation?.longitude else { return }
                guard let latitude = response?.result?.geometryLocation?.latitude else { return }

                let country = response?.result?.addressComponents.first(where: { addressComponent in
                    addressComponent.types.contains("country")
                })

                let city = response?.result?.addressComponents.first(where: { addressComponent in
                    addressComponent.types.contains("locality")
                })

                let locationItem = Location(city: city?.longName ?? "",
                                            country: country?.longName ?? "",
                                            latitude: latitude,
                                            longitude: longitude)

                self.completionBlock(locationItem)

                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Error: ", error.localizedDescription)
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}
