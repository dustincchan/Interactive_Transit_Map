//
//  ViewController.swift
//  Bart Now
//
//  Created by Dustin Chan on 12/21/16.
//  Copyright © 2016 Dustin Chan. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let initialLocation = CLLocation(latitude: 37.8970287, longitude: -122.1420556)
    let regionRadius: CLLocationDistance = 10000
    
    // initialize station datasource that holds an array of station json
    var stationDatasource: [[String: String]] = []
    var stationAnnotations: [Station] = []
    
    var currentlyFilteredAnnotations: [Station] = []
    var isFilteredToSingleLocation = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the map
        self.mapView.mapType = MKMapType.standard
        self.mapView.delegate = self
        self.parseStationList()
        centerMapOnLocation(location: initialLocation)
        
        // set the pins for all stations
        for stationData in stationDatasource {
            let stationObj = Station(stationName: stationData["name"]!, stationDetails: "\(stationData["address"]!), \(stationData["city"]!) \(stationData["zipcode"]!)", coordinate: CLLocationCoordinate2D(latitude: Double(stationData["gtfs_latitude"]!)!, longitude: Double(stationData["gtfs_longitude"]!)!))
            stationAnnotations.append(stationObj)
            
            // add every single annotation upon app loading
            self.mapView.addAnnotation(stationObj)
        }
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 6, regionRadius * 6)
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
    
    // search bar stuff
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // remove all current annotations and re-add only the ones that match the query string
        filterMapToSearchBarText(searchBarText: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // zoom out to default
        centerMapOnLocation(location: initialLocation)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // zoom out then filter to what's already in the searchbar
        centerMapOnLocation(location: initialLocation)
        currentlyFilteredAnnotations = []
        isFilteredToSingleLocation = false
        filterMapToSearchBarText(searchBarText: searchBar.text)
    }
    
    func filterMapToSearchBarText(searchBarText: String?) {
        print(searchBarText!)
        if searchBarText == "" {
            self.mapView.addAnnotations(stationAnnotations)
            centerMapOnLocation(location: initialLocation)
        } else {
            
            // filter the datasource of annotations to our searchbar text
            let filteredAnnotations = self.stationAnnotations.filter() {station in
                return station.title!.lowercased().range(of: searchBarText!.lowercased()) != nil
            }
            if filteredAnnotations != currentlyFilteredAnnotations {
                // remove and re-add all annotations that passed a filter
                self.mapView.removeAnnotations(stationAnnotations)
                self.mapView.addAnnotations(filteredAnnotations)
                self.currentlyFilteredAnnotations = filteredAnnotations
                
                // if the user filtered down to a single station, zoom into it
                if filteredAnnotations.count == 1 && isFilteredToSingleLocation == false {
                    mapView.selectAnnotation(filteredAnnotations.first!, animated: true)
                    let zoomedLocation = filteredAnnotations.first!.coordinate
                    let zoomedCoordinateRegion = MKCoordinateRegionMakeWithDistance(zoomedLocation, regionRadius * 3.0, regionRadius * 3.0)
                    mapView.setRegion(zoomedCoordinateRegion, animated: true)
                    isFilteredToSingleLocation = true
                } else if filteredAnnotations.count != 1 {
                    // zoom out when the user deletes his/her search or there's more than 1 filterable station
                    centerMapOnLocation(location: initialLocation)
                    isFilteredToSingleLocation = false
                }
            }
            
        }
    }
    
    // parse station JSON data
    func parseStationList() {
        if let path = Bundle.main.path(forResource: "StationList", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    self.stationDatasource = jsonObj["root"]["stations"]["station"].arrayObject as! [[String: String]]
                    print(self.stationDatasource)
                } else {
                    print("JSON file is corrupted")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
}

