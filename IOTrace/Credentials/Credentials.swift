//
//  Credentials.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

let credentialsDict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "BMSCredentials", ofType: "plist")!) as! [String: AnyObject]

enum Credential {
    case iotpHTTPHost, iotpMQTTHost, iotpToken
}

class IOTPCredentials {
    static let org = credentialsDict["iotplatformOrg1"] as! String
    static let apiKey = credentialsDict["iotplatformApiKey1"] as! String
    static let token = credentialsDict["iotplatformApiToken1"] as! String
    
    static let username = IOTPCredentials.apiKey
    static let password = IOTPCredentials.token
    
    static let mqttPort = credentialsDict["iotplatformMqtt_s_port"] as! Int
    
    static let clientID = "a:\(IOTPCredentials.org):\(IOTPCredentials.apiKey)"
    static let host = "\(IOTPCredentials.org).messaging.internetofthings.ibmcloud.com"
}
