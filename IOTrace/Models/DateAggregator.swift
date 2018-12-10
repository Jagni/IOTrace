//
//  DateAggregator.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import CoreLocation

class DateAggregator : Comparable {
    var date : String?

    var intervals = [LocationInterval]()
    var luminances = [LuminanceEvent]()
    
    static func < (lhs: DateAggregator, rhs: DateAggregator) -> Bool {
        if let lhsDate = lhs.date {
            if let rhsDate = rhs.date {
                return lhsDate < rhsDate
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    static func == (lhs: DateAggregator, rhs: DateAggregator) -> Bool {
        return lhs.date == rhs.date
    }
    
    func appendLocation(_ location: LocationEvent) -> Bool{
        if self.date != nil && location.dateString != self.date {
            return false
        }
        
        var added = false
        
        for interval in self.intervals {
            added = interval.appendLocation(location)
            if added {
                return true
            }
        }
        
        let interval = LocationInterval()
        _ = interval.appendLocation(location)
        
        if self.date == nil {
            self.date = location.dateString
        }
        interval.date = self.date
        self.intervals.append(interval)
        return true
    
    }
}
