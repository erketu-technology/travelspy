//
//  MapView.swift
//  TravelSpy
//
//  Created by AlexK on 29/12/2021.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let post: Post
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: post.placemark.latitude, longitude: post.placemark.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        )
        mapView.region = region
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: post.placemark.latitude, longitude: post.placemark.longitude)
        mapView.addAnnotation(annotation)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, post: post)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        var post: Post
        
        init(parent: MapView, post: Post) {
            self.parent = parent
            self.post = post
        }
    }
    
}
