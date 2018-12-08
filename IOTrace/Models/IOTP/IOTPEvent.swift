//
//  IOTPEvent.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON

class IOTPEvent {
    var timestamp = ""
    var id = ""
    
    init(json: JSON) {
        self.timestamp = json["timestamp"].stringValue
        self.id = json["id"].stringValue
    }
    
    var date : Date {
        return self.timestamp
    }
}
