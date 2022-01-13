//
//  MapView.swift
//  TravelSpy
//
//  Created by AlexK on 29/12/2021.
//

import Foundation
import SwiftUI
import MapKit
import Firebase
import FirebaseFirestoreSwift

struct MapView: UIViewRepresentable {
    let location: Location
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        )
        mapView.region = region
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        mapView.addAnnotation(annotation)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, location: location)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        var location: Location
        
        init(parent: MapView, location: Location) {
            self.parent = parent
            self.location = location
        }
    }
    
}
