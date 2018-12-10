//
//  LocationEvent.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleMaps

class LocationEvent : IOTPEvent {
    var latitude : Double!
    var longitude : Double!
    var accuracy : Double!
    var marker : GMSMarker?
    var circle : GMSMarker?
    
    override init(json: JSON) {
        self.latitude = json["data"]["lat"].doubleValue
        self.longitude = json["data"]["lon"].doubleValue
        self.accuracy = json["data"]["accuracy"].doubleValue
        super.init(json: json)
    }
}
