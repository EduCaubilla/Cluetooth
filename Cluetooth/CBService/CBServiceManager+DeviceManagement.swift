//
//  CBServiceManager+DeviceManagement.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 19/9/25.
//

import Foundation
import CoreBluetooth

extension CBServiceManager {
    //MARK: - Device Management
    func setDeviceConnectionState(_ peripheral: CBPeripheral, connecting: Bool, connected: Bool) {
        if let index = discoveredDevices.firstIndex(where: {$0.uid == peripheral.identifier}) {
            discoveredDevices[index].connecting = connecting
            discoveredDevices[index].connected = connected
        }
    }

    func updateConnectedDeviceState(_ peripheral: CBPeripheral) {
        connectedDevice = discoveredDevices.first(where: {$0.uid == peripheral.identifier})
        setDeviceConnectionState(peripheral, connecting: false, connected: true)
    }

    func removeConnectedDevice(_ peripheral: CBPeripheral) {
        setDeviceConnectionState(peripheral, connecting: false, connected: false)
        if connectedDevice?.uid == peripheral.identifier {
            connectedDevice = nil
        }
        connectedPeripheral = nil
    }

    //MARK: - Device Connected Management
    func setConnectedDeviceServices(_ peripheral: CBPeripheral) {
        if let foundServicesForDevice = peripheral.services {
            connectedDevice?.services = foundServicesForDevice
        }
    }

    func setConnectedDeviceCharacteristicForService(_ peripheral: CBPeripheral, _ service: CBService) {
        if let connectedServices = connectedDevice?.services {
            for var connectedService in connectedServices {
                if connectedService.uuid == service.uuid {
                    connectedService = service
                }
            }
        }
    }

    func updateConnectedDeviceCharacteristicForService(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        let linkedDevice = discoveredDevices.first(where: {$0.peripheral?.identifier == peripheral.identifier})
        guard linkedDevice == linkedDevice else { return }

        print("Updated Characteristic \(characteristic.uuid) for device: \(peripheral.name ?? "Unknown Device")")
    }
}
