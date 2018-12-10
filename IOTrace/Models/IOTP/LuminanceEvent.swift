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
    
    var luxLabel : String {
        if self.lux <= 200 {
            return "Gaveta ou recipiente fechado e escuro"
        } else if self.lux <= 400 {
            return "Sala ou corredor com pouca luz"
        } else if self.lux <= 600 {
            return "Sala ou corredor iluminado"
        } else {
            return "Local a céu aberto ou com luz direta"
        }
    }
    
    override init(json: JSON) {
        self.lux = json["data"]["luminance"].doubleValue
        super.init(json: json)
    }
    
    static func == (lhs: LuminanceEvent, rhs: LuminanceEvent) -> Bool {
        return lhs.lux == rhs.lux
    }
    
}
