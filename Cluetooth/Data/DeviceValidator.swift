//
//  DeviceValidator.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 19/9/25.
//

import Foundation

struct DeviceValidator {
    static func isConnectable(_ device: Device) -> Bool {
        return (device.advertisementData.contains(where: { $0.key == ServiceAdvertisementDataKey.CBAdvertisementDataIsConnectable.displayName }))
        && device.advertisementData[ServiceAdvertisementDataKey.CBAdvertisementDataIsConnectable.displayName] == "Yes"
    }
}
