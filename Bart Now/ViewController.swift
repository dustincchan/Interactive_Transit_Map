//
//  ViewController.swift
//  Bart Now
//
//  Created by Dustin Chan on 12/21/16.
//  Copyright © 2016 Dustin Chan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let initialLocation = CLLocation(latitude: 37.8970287, longitude: -122.1420556)
    let regionRadius: CLLocationDistance = 10000
    
    // initialize all the different stations
    let walnutCreek = Station(stationName: "Walnut Creek", coordinate: CLLocationCoordinate2D(latitude: 37.8936405, longitude: -122.0898525))
    let pleasantHill = Station(stationName: "Pleasant Hill", coordinate: CLLocationCoordinate2D(latitude: 37.8935523, longitude: -122.1949206))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the map
        self.mapView.mapType = MKMapType.standard
        self.mapView.delegate = self
        centerMapOnLocation(location: initialLocation)
        
        // set the pins for all stations
        self.mapView.addAnnotation(walnutCreek)
        self.mapView.addAnnotation(pleasantHill)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 5.0, regionRadius * 5.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // show custom image with the exception of the user's current location
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // annotation view configuration here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "station_icon")
        }
        
        return annotationView
    }
}

