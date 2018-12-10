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
    var locationManager = CLLocationManager()
    var selectedTime : String?
    var markerPairs = [GMSMarker : GMSCircle]()
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
        view = mapView
        
    }
    
    func loadMarkers(aggregator: DateAggregator, detailed: Bool){
        DispatchQueue.main.async {
            self.mapView.clear()
            self.markerPairs.removeAll()
            if aggregator.intervals.count > 0{
                if detailed {
                    for interval in aggregator.intervals {
                        for location in interval.locations{
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                            marker.title = location.timeString
                            marker.snippet = "Latitude: \(location.latitude!)º\nLongitude:\(location.longitude!)º"
                            marker.icon = GMSMarker.markerImage(with: markerColor)
                            marker.map = self.mapView
                            
                            let circle = GMSCircle(position: marker.position, radius: location.accuracy)
                            circle.fillColor = unselectedCircleColor
                            circle.strokeColor = UIColor.white
                            circle.strokeWidth = 2
                            
                            circle.map = self.mapView
                            
                            self.markerPairs[marker] = circle
                        }
                    }
                } else {
                    let interval = aggregator.intervals.first!
                    let location = interval.locations.first!
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    marker.title = "\(location.timeString)"
                    marker.icon = GMSMarker.markerImage(with: markerColor)
                    if interval.locations.count > 1 {
                        marker.title = "\(location.timeString) - \(interval.locations.last!.timeString)"
                    }
                    marker.snippet = "Latitude: \(location.latitude!)º\nLongitude:\(location.latitude!)º"
                    marker.map = self.mapView
                    
                    let circle = GMSCircle(position: marker.position, radius: location.accuracy)
                    circle.fillColor = unselectedCircleColor
                    circle.strokeColor = UIColor.white
                    circle.strokeWidth = 3
                    circle.map = self.mapView
                    
                    self.markerPairs[marker] = circle
                }
            } else {
                //Show Empty View
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    

    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        selectedTime = marker.title
        
        for iterator in markerPairs{
            iterator.value.fillColor = UIColor.white.withAlphaComponent(0)
            iterator.value.strokeColor = UIColor.white.withAlphaComponent(0)
        }
        
        let circle = markerPairs[marker]!
        circle.fillColor = selectedCircleColor
        circle.strokeColor = markerColor
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
//        for iterator in markerPairs{
//            iterator.value.fillColor = unselectedCircleColor
//            iterator.value.strokeColor = UIColor.white
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        DispatchQueue.main.async {
            let location = locations.last
            
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 10)
            
            self.mapView.animate(to: camera)
            
            //Finally stop updating location otherwise it will come again and again in this delegate
            self.locationManager.stopUpdatingLocation()
        }
        
    }
}
