//
//  MainContainerController.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit
import CocoaMQTT
import SwiftyJSON

class MainContainerController: UIViewController {
    
    // Logger
    // Cloudant Driver
    var client: CloudantViewModel?
    var mapController: MapViewController!
    var dateController: DateCollectionController!
    
    override func viewDidLoad() {
        
        // Register observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        mqttClient.username = IOTPCredentials.username
        mqttClient.password = IOTPCredentials.password
        mqttClient.keepAlive = 60
        mqttClient.delegate = self
        
        // Set up Cloudant Driver
        configureCloudant()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "map" {
            let controller = segue.destination as! MapViewController
            self.mapController = controller
        }
        if segue.identifier == "date" {
            let controller = segue.destination as! DateCollectionController
            self.dateController = controller
        }
        self.client?.retrieveItems()

    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Callback for view becoming active
    @objc func didBecomeActive(notification: NSNotification) {
    }
    
    // Refresh Handler
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {        self.client?.retrieveItems()
        refreshControl.endRefreshing()
    }
    
    // Setup cloudant driver
    func configureCloudant() {
        
        // Retrieve plist
        guard let path = Bundle.main.path(forResource: "BMSCredentials", ofType: "plist"),
            let credentials = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
                return
        }
        
        // Retrieve credentials
        guard let userId = credentials["cloudantUsername"] as? String, !userId.isEmpty,
            let password = credentials["cloudantPassword"] as? String, !password.isEmpty,
            let url = credentials["cloudantUrl"] as? String, !url.isEmpty, let cloudantURL = URL(string: url) else {
                showError(.missingCredentials)
                return
        }
        
        self.client = CloudantViewModel(userId: userId, password: password, cloudantURL: cloudantURL)
        self.client?.delegate = self
        self.client?.retrieveItems()
    }
}

extension MainContainerController: CloudantDataReceiver {
    
    // Callback method to reload the tableview when more data is available
    func didRecieveItems() {
        if let aggregator = self.client?.dateAggregations.first {
            self.mapController.loadMarkers(aggregator: aggregator, detailed: true)
        }
        self.dateController.reloadDates(newDates: self.client?.dateAggregations, detailed: true)
    }
    
    // Display alert error
    func showError(_ error: ApplicationError) {
        // Log Error
        DispatchQueue.main.async {
            if self.presentedViewController == nil {
                // Set alert properties
                let alert = UIAlertController(title: error.title, message: error.description, preferredStyle: .alert)
                // Add an action to the alert
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                // Show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension MainContainerController : CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        mqttClient.subscribe("2/type/\(trackedDevice.type)/id/\(trackedDevice.id)/evt/+/fmt/json")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        var json : JSON = JSON.null
        if let message = message.string {
            json = JSON.init(parseJSON: message)
        } else {
            return  // do nothing
        }
        let locationTopic = "iot-2/type/\(trackedDevice.type)/id/\(trackedDevice.id)/evt/location/fmt/json"
        let lostCommand = "iot-2/type/\(trackedDevice.type)/id/\(trackedDevice.id)/cmd/lost/fmt/json"

        switch message.topic {
        case locationTopic:
            //ObjectStorage
            break
        case lostCommand:
            break
        default:
            break
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        
    }
    
    
}
