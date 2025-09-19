//
//  CBServiceManager+PeripheralDelegate.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 19/9/25.
//

import Foundation
import CoreBluetooth

extension CBServiceManager: CBPeripheralDelegate {
    //MARK: - Services found
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            updateState(.error(error!.localizedDescription))
            return
        }

        guard let services = peripheral.services else {
            print("Peripheral services array is nil")
            updateState(.error("Peripheral services array is nil"))
            return
        }

        print("Discovered services for \(peripheral.name ?? "Unnamed peripheral")")

        setDeviceConnectionState(peripheral, connecting: false, connected: true)
        setConnectedDeviceServices(peripheral)

        for service in services {
            print("Discovering characteristics for service \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    //MARK: - Get characteristics from services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard error == nil else {
            print("Error discovering characteristics for service \(service.uuid): \(error!.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else {
            print("Characteristics array for service \(service.uuid) is nil")
            return
        }

        print("Discovered characteristics for service \(service.uuid): ")

        for characteristic in characteristics {
            self.characteristics[characteristic.uuid] = characteristic
            print("Characteristic \(characteristic.uuid) added with properties: \(characteristic.properties)")

            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to notifications for \(characteristic.uuid)")
            }

            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
                print("Read value for \(characteristic.uuid)")
            }
        }

        setConnectedDeviceCharacteristicForService(peripheral, service)
    }

    //MARK: - Updated characteristic for a service
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard error == nil else {
            print("Error reading characteristic: \(error!.localizedDescription)")
            return
        }

        guard let data = characteristic.value else {
            print("No data received for characteristic \(characteristic.uuid)")
            return
        }

        print("Received data for \(characteristic.uuid): \(data)")

        updateConnectedDeviceCharacteristicForService(peripheral, characteristic)
    }

    //MARK: - Wrote value in a characteristic
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            print("Error writing to characteristic \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            print("Succesfully wrote value for \(characteristic.uuid): \(String(describing: characteristic.value))")
        }
    }
}
