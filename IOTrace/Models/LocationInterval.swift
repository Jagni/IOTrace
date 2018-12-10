//
//  DateAggregator.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import CoreLocation

class LocationInterval : Comparable {
    var date : String!
    var oldestTime : Date? {
        return locations.last?.date
    }
    var latestTime : Date? {
        return locations.first?.date
    }
    var locations = [LocationEvent]()
    
    static func < (lhs: LocationInterval, rhs: LocationInterval) -> Bool {
        if let lhsDate = lhs.oldestTime {
            if let rhsDate = rhs.oldestTime {
                return lhsDate < rhsDate
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    static func == (lhs: LocationInterval, rhs: LocationInterval) -> Bool {
        return lhs.date == rhs.date
    }
    
    func appendLocation(_ location: LocationEvent) -> Bool{
            
        if locations.count == 0 {
            self.locations.append(location)
            return true
        }
        
        let possibleLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let baseLocation = CLLocation(latitude: locations.first!.latitude, longitude: locations.first!.longitude)
        
        if baseLocation.distance(from: possibleLocation) <= location.accuracy + locations.first!.accuracy {
            self.locations.append(location)
            self.locations.sort()
            return true
        }
        
        return false
    }
}
