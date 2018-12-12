//
//  MQTTManager.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 07/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import CocoaMQTT

let mqttClient = CocoaMQTT(clientID: IOTPCredentials.clientID,
                           host: IOTPCredentials.host, port: UInt16(IOTPCredentials.mqttPort!))

var trackedDevice = IOTPDevice()

class MQTTManager {
    static func sendLostCommand(value: Bool, device: IOTPDevice = IOTPDevice()){
        let topic = "iot-2/type/\(device.type)/id/\(device.id)/cmd/lost/fmt/json"
        let message = CocoaMQTTMessage(topic: topic, string: "{value: \(value ? "true" : "false")}")
        mqttClient.publish(message)
    }
}
