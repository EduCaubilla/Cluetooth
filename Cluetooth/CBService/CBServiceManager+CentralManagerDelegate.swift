//
//  CBServiceManager+CentralManagerDelegate.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 19/9/25.
//

import Foundation
import CoreBluetooth

extension CBServiceManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let newState: BluetoothState

        switch central.state {
            case .unknown:
                newState = .unknown
            case .resetting:
                newState = .resetting
            case .unsupported:
                newState = .unsupported
            case .unauthorized:
                newState = .unauthorized
            case .poweredOff:
                newState = .poweredOff
            case .poweredOn:
                newState = .poweredOn
            @unknown default:
                newState = .unknown
        }

        updateState(newState)

        print("Central Manager State changed to: \(central.state.rawValue) -> \(newState)")
    }

    //MARK: - Discover Device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = DeviceFactory.createDevice(
            peripheral: peripheral,
            advertisementData: advertisementData,
            RSSI: RSSI)

        guard let device = device else { return }

        // In case that has no name only connectables will show
        let isConnectable = DeviceValidator.isConnectable(device)
        if device.name == "Unknown Name" && !isConnectable {
            return
        }

        addOrUpdateDevice(device)
    }

    //MARK: - Connect Device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Peripheral")")

        connectionTimer?.invalidate()
        connectionTimer = nil

        connectedPeripheral = peripheral
        updateState(.connected)
        updateConnectedDeviceState(peripheral) //TODO

        peripheral.delegate = self

        if targetServiceUUIDs.isEmpty {
            peripheral.discoverServices(nil)
        } else {
            peripheral.discoverServices(targetServiceUUIDs)
        }
    }

    //MARK: - Failed connection
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown Error")")

        connectionTimer?.invalidate()
        connectionTimer = nil

        updateState(.error(error?.localizedDescription ?? "Connection Failed"))
    }

    //MARK: - Disconnect device
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Disconnected to \(peripheral.name ?? "Unknown Peripheral")")

        if let error = error {
            print("Disconnect Error: \(error.localizedDescription)")
            updateState(.error(error.localizedDescription))
        }

        resetConnection()
        removeConnectedDevice(peripheral)
    }
}
