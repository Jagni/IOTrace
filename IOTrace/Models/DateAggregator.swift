//
//  DateAggregator.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
class DateAggregator {
    var locations = [LocationEvent]()
    var luminances = [LuminanceEvent]()
    
    var oldestDate : Date? {
        return locations.first?.date
    }
}
