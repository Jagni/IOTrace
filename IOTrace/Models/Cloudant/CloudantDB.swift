//
//  CloudantDB.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 08/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

class CloudantDB : Comparable {
    var year : Int
    var month : Int
    static func < (lhs: CloudantDB, rhs: CloudantDB) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year > rhs.year
        } else {
            return lhs.month > rhs.month
        }
    }
    
    static func == (lhs: CloudantDB, rhs: CloudantDB) -> Bool {
        return lhs.year == rhs.year && lhs.month > rhs.month
    }
    
    init(name: String){
        let dateString = name.replacingOccurrences(of: "iotp_39ps2j_devices_", with: "")
        let stringArray = dateString.split(separator: "-")
        self.year = Int(stringArray.first!)
        self.month = Int(stringArray.last!)
    }
}
