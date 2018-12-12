//
//  IOTPEvent.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftDate

class IOTPEvent : Comparable {
    static func < (lhs: IOTPEvent, rhs: IOTPEvent) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func == (lhs: IOTPEvent, rhs: IOTPEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    var timestamp = ""
    var id = ""
    
    init(json: JSON) {
        self.timestamp = json["timestamp"].stringValue
        self.id = json["id"].stringValue
    }
    
    init(smallJSON: JSON) {
        self.timestamp = Date().toISO()
        self.id = self.timestamp
    }
    
    var date : Date {
        return self.timestamp.toISODate(nil, region: Region.current)!.date
    }
    
    var dateString : String {
        
        return self.date.toFormat("dd/MM/yyyy")
    }
    
    var timeString : String {
        return self.date.toString(.time(.short))
    }
}
