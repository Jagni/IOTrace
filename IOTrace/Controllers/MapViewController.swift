//
//  MapViewController.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps


class MapViewController : UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    var delegate : MapControllerDelegate?
    var locationManager = CLLocationManager()
    var selectedTime : String?
    var markerPairs = [String : LocationEvent]()
    var mapView : GMSMapView {
        return self.view as! GMSMapView
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
//        do {
//            // Set the map style by passing the URL of the local file.
//            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
//                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//            } else {
//                NSLog("Unable to find style.json")
//            }
//        } catch {
//            NSLog("One or more of the map styles failed to load. \(error)")
//        }
        view = mapView
        
    }
    
    func setDetailed(_ value: Bool){
        DispatchQueue.main.async {
            self.mapView.padding = UIEdgeInsets(top: 120, left: 0, bottom: value ? 120 : 0, right: 0)
        }
    }
    
    func moveToMarker(){
        DispatchQueue.main.async {
            if let marker = self.markerPairs.first{
                self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: marker.value.latitude, longitude: marker.value.longitude) )
            }
        }
    }
    
    func loadMarkers(dateAggregator: DateAggregator?, detailed: Bool){
        DispatchQueue.global(qos: .background).async {
            
        DispatchQueue.main.sync {
            self.mapView.clear()
        }
        self.markerPairs.removeAll()

            if let aggregator = dateAggregator{
                if aggregator.intervals.count > 0{
                    if detailed {
                        for interval in aggregator.intervals {
                            for location in interval.locations{
                                DispatchQueue.main.sync {
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                marker.title = location.timeString
                                marker.snippet = "Latitude: \(location.latitude!)º\nLongitude:\(location.longitude!)º"
                                marker.icon = GMSMarker.markerImage(with: markerColor)
                                marker.map = self.mapView
                                
                                self.markerPairs["\(marker.position.latitude),\(marker.position.longitude)"] = location
                                }
                            }
                        }
                    } else {
                        for interval in aggregator.intervals {
                            if let location = interval.locations.first, let lastLocation = interval.locations.last{
                                DispatchQueue.main.sync {
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                
                                marker.icon = GMSMarker.markerImage(with: markerColor)

                                marker.title = "\(location.timeString)"
                                
                                if interval.locations.count > 1 {
                                    marker.title = "\(location.timeString) - \(lastLocation.timeString)"
                                }
                                
                                let luminance = aggregator.luminances.first(where: { (event) -> Bool in
                                    event.date >= location.date
                                })
                                marker.snippet = luminance?.luxLabel
                                marker.map = self.mapView
                                
                                let circle = GMSCircle(position: marker.position, radius: location.accuracy)
                                circle.fillColor = unselectedCircleColor
                                circle.strokeColor = UIColor.white
                                circle.strokeWidth = 3
                                circle.map = self.mapView
                                
                                self.markerPairs["\(marker.position.latitude),\(marker.position.longitude)"] = location
                                }
                            }
                        }
                    }
                } else {
                    //Show Empty View
                }
            } else {
                //Show Empty view
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        DispatchQueue.main.async {
            self.delegate?.didSelectMarker(location: self.markerPairs["\(marker.position.latitude),\(marker.position.longitude)"]!)
        }
        
        return false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        DispatchQueue.main.async {
            let location = locations.last
            
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15)
            
            self.mapView.animate(to: camera)
            
            //Finally stop updating location otherwise it will come again and again in this delegate
            self.locationManager.stopUpdatingLocation()
        }
        
    }
}
