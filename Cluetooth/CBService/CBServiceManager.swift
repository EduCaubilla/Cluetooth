//
//  CBServiceManager.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 3/9/25.
//

import Foundation
import CoreBluetooth

class CBServiceManager: NSObject, ObservableObject, CBServiceManagerProtocol {
    //MARK: - PROPERTIES
    @Published var state: BluetoothState
    @Published var discoveredDevices: [Device]
    @Published var connectedDevice: Device?
    @Published var isScanning: Bool

    private let centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    private var connectedPeripheral: CBPeripheral?
    private var targetServiceUUIDs: [CBUUID] = []
    private var characteristics: [CBUUID: CBCharacteristic] = [:]

    private let scanTimeout: TimeInterval = 25.0
    private var scanTimer: Timer?

    //MARK: - INITIALIZER
    override init() {
        centralManager = .init(delegate: nil, queue: nil)

        super.init()
        centralManager.delegate = self
    }

    //MARK: - FUNCTIONS
    func startScanning(for serviceUUIDs: [CBUUID]? = nil) {
         guard centralManager.state == .poweredOn else {
            state = .poweredOff
            return
        }

        targetServiceUUIDs = serviceUUIDs ?? []
        isScanning = true
        centralManager.scanForPeripherals(
            withServices: targetServiceUUIDs,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )

        scanTimer = Timer.scheduledTimer(withTimeInterval: scanTimeout, repeats: false, block: { _ in
            self.stopScanning()
        })

        print("Started scanning...")
    }

    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        scanTimer?.invalidate()
        scanTimer = nil

        if state == .connecting {
            state = .poweredOn
        }

        print("Stopped scanning.")
    }

    func connect(to device: Device) {
        stopScanning()
        state = .connecting
        centralManager.connect(device.peripheral, options: nil)

        connectedDevice = device
        print("Trying to connect to \(device.name)...")
    }

    func disconnect(from device: Device) {
        guard device.name.isEmpty else { return }
        centralManager.cancelPeripheralConnection(device.peripheral)

        print("Disconnecting from peripheral ")
    }

    func writeData(_ data: Data, to characteristicUUID: CBUUID) {
        guard let peripheral = connectedDevice,
              let characteristic = characteristics[characteristicUUID] else {
            print("Cannot write: peripheral or characteristic not available.")
            return
        }

        let writeType: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse
        peripheral.peripheral.writeValue(data, for: characteristic, type: writeType)
        print("Write data for characteristic: \(characteristicUUID)")
    }

    func readValue(for characteristicUUID: CBUUID) {
        guard let peripheral = connectedDevice?.peripheral,
              let characteristic = characteristics[characteristicUUID] else {
            print("Cannot read: peripheral or characteristic not available.")
            return
        }
        
        peripheral.readValue(for: characteristic)
        print("Read value for characteristic: \(characteristicUUID)")
    }

    func resetConnection(){
        connectedPeripheral = nil
        connectedDevice = nil
        characteristics.removeAll()
        stopScanning()
    }
}

extension CBServiceManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                state = .unknown
            case .resetting:
                state = .resetting
            case .unsupported:
                state = .unsupported
            case .unauthorized:
                state = .unauthorized
            case .poweredOff:
                state = .poweredOff
            case .poweredOn:
                state = .poweredOn
            @unknown default:
                state = .unknown
        }
        print("Central Manager State changed to: \(central.state.rawValue) -> \(state)")
    }

    //MARK: - Discover Devices
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Peripheral"

        let device = Device(
            peripheral: peripheral,
            name: peripheral.name ?? "Unknown Peripheral",
            services: advertisementData,
            rssi: RSSI.intValue
        )

        if !discoveredDevices.contains(device) {
            discoveredDevices.append(device)
            print("Device found \(deviceName)")
        }
    }

    //MARK: - Connect Device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Peripheral")")

        connectedPeripheral = peripheral
        peripheral.delegate = self
        state = .connected

        if targetServiceUUIDs.isEmpty {
            peripheral.discoverServices(nil)
        } else {
            peripheral.discoverServices(targetServiceUUIDs)
        }
    }

    //MARK: - Failed connection
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown Error")")
        state = .error(error?.localizedDescription ?? "Connection Failed")
    }

    //MARK: - Disconnect device
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Disconnected to \(peripheral.name ?? "Unknown Peripheral")")

        if let error = error {
            print("Disconnect Error: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }

        resetConnection()
    }
}

extension CBServiceManager: CBPeripheralDelegate {
    //MARK: - Services found
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard error == nil else {
            print("Error disconvering services: \(error!.localizedDescription)")
            state = .error(error!.localizedDescription)
            return
        }

        guard let services = peripheral.services else {
            print("Peripheral services array is nil")
            state = .error("Peripheral services array is nil")
            return
        }
        
        print("Discovered services: ")
        dump(services)

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
        dump(characteristics)

        for characteristic in characteristics {
            self.characteristics[characteristic.uuid] = characteristic
            print("Characteristic \(characteristic.uuid) added with properties: \(characteristic.properties)")

            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to notifications for \(characteristic.uuid)")
            }
        }
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
        
        print("Received data for \(characteristic.uuid): \(String(decoding: data, as: Unicode.UTF8.self))")

        handleReceivedData(data)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            print("Error writing to characteristic \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            print("Succesfully wrote value for \(characteristic.uuid): \(String(describing: characteristic.value))")
        }
    }

    func handleReceivedData(_ data: Data) {
        print("Received data for handling: ")
        dump(data)
    }
}

enum BluetoothState : Equatable {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    case scanning
    case connecting
    case connected
    case disconnected
    case error(String)
}
