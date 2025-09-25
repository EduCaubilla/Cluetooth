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
            AppLogger.error("Error discovering services: \(error!.localizedDescription)", error: error)
            updateState(.error(error!.localizedDescription))
            return
        }

        guard let services = peripheral.services else {
            AppLogger.warning("Peripheral services array is nil")
            updateState(.error("Peripheral services array is nil"))
            return
        }

        AppLogger.info("Discovered services for \(peripheral.name ?? "Unnamed peripheral")")

        setDeviceConnectionState(peripheral, connecting: false, connected: true)
        setConnectedDeviceServices(peripheral)

        for service in services {
            AppLogger.info("Discovering characteristics for service \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    //MARK: - Get characteristics from services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard error == nil else {
            AppLogger.error("Error discovering characteristics for service \(service.uuid): \(error!.localizedDescription)", error: error)
            return
        }

        guard let characteristics = service.characteristics else {
            AppLogger.warning("Characteristics array for service \(service.uuid) is nil")
            return
        }

        AppLogger.info("Discovered characteristics for service \(service.uuid): ")

        for characteristic in characteristics {
            self.characteristics[characteristic.uuid] = characteristic
            AppLogger.info("Characteristic \(characteristic.uuid) added with properties: \(characteristic.properties)")

            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                AppLogger.info("Subscribed to notifications for \(characteristic.uuid)")
            }

            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
                AppLogger.info("Read value for \(characteristic.uuid)")
            }
        }

        setConnectedDeviceCharacteristicForService(peripheral, service)
    }

    //MARK: - Updated characteristic for a service
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard error == nil else {
            AppLogger.error("Error reading characteristic: \(error!.localizedDescription)", error: error)
            return
        }

        guard let data = characteristic.value else {
            AppLogger.warning("No data received for characteristic \(characteristic.uuid)")
            return
        }

        updateConnectedDeviceCharacteristicForService(peripheral, characteristic)

        if "\(characteristic.uuid)" == "Continuity" { return }
        AppLogger.info("Received data for \(characteristic.uuid): \(data)")
    }

    //MARK: - Wrote value in a characteristic
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            AppLogger.error("Error writing to characteristic \(characteristic.uuid): \(error.localizedDescription)", error: error)
        } else {
            AppLogger.info("Succesfully wrote value for \(characteristic.uuid): \(String(describing: characteristic.value))")
        }
    }
}
