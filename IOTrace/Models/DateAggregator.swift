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
    var compareDate : Date?
    var intervals = [LocationInterval]()
    var luminances = [LuminanceEvent]()
    
    static func < (lhs: DateAggregator, rhs: DateAggregator) -> Bool {
        return lhs.compareDate! < rhs.compareDate!
    }
    
    static func == (lhs: DateAggregator, rhs: DateAggregator) -> Bool {
        return lhs.date == rhs.date && lhs.intervals == rhs.intervals && lhs.luminances == rhs.luminances
    }
    
    func appendLuminance(_ luminance: LuminanceEvent) -> Bool{
        if self.date != nil {
            if luminance.dateString != self.date {
                return false
            } else {
                luminances.insert(luminance, at: 0)
                return true
            }
        } else {
            luminances.insert(luminance, at: 0)
            self.date = luminance.dateString
            self.compareDate = luminance.date
            return true
        }
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
            self.compareDate = location.date
        }
        interval.date = self.date
        self.intervals.append(interval)
        return true
        
    }
}
