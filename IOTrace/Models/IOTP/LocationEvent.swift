//
//  LocationEvent.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

class LocationEvent : IOTPEvent {
    var latitude : Double!
    var longitude : Double!
    var accuracy : Double!
    
    override init(json: JSON) {
        self.latitude = json["latitude"].doubleValue
        self.longitude = json["longitude"].doubleValue
        self.accuracy = json["accuracy"].doubleValue
        super.init(json: json)
    }
}
