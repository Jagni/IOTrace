//
//  LuminanceEvent.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

class LuminanceEvent : IOTPEvent {
    var lux : Double!
    
    override init(json: JSON) {
        self.lux = json["lux"].doubleValue
        super.init(json: json)
    }
    
}
