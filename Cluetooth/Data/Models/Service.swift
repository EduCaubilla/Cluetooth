//
//  Service.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 18/9/25.
//

import Foundation
import CoreBluetooth

struct Service: Equatable {
    let uid: String = UUID().uuidString
    let name: String
    let characteristics: [String : String]

    init(name: String, characteristics: [String : String]) {
        self.name = name
        self.characteristics = characteristics
    }

    init(service: CBService) {
        self.name = BluetoothUUIDMapper.getServiceDescription(for: service.uuid.uuidString)
        self.characteristics = Device.characteristicConverter(for: service.characteristics ?? [])
    }
}
