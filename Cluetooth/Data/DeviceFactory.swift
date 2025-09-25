//
//  DeviceFactory.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 19/9/25.
//

import Foundation
import CoreBluetooth

struct DeviceFactory {
    static func createDevice(peripheral : CBPeripheral?, advertisementData: [String : Any], RSSI: NSNumber) -> Device? {
        let deviceName = peripheral?.name
        ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
        ?? "Unknown Name"

        return Device(
            peripheral: peripheral ?? nil,
            name: deviceName,
            advertisementData: Device.advDataConverter(advertisementData),
            services: [],
            rssi: RSSI.intValue,
            timestamp: nil
        )
    }
}
