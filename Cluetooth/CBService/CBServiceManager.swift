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
    static let shared = CBServiceManager()

    @Published var state: BluetoothState
    @Published var discoveredDevices: [Device]
    @Published var connectedDevice: Device?
    @Published var isScanning: Bool

    private var centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    private var connectedPeripheral: CBPeripheral?
    private var targetServiceUUIDs: [CBUUID] = []
    private var characteristics: [CBUUID: CBCharacteristic] = [:]

    private let scanTimeout: TimeInterval = 10.0
    private var scanTimer: Timer?

    //MARK: - INITIALIZER
    override init() {
        state = .unknown
        discoveredDevices = []
        connectedDevice = nil
        isScanning = false
        peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        centralManager = CBCentralManager(delegate: nil, queue: nil)

        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    //MARK: - FUNCTIONS
    //MARK: - Scan
    func startScanning(for serviceUUIDs: [CBUUID]? = nil) {
        centralManagerDidUpdateState(centralManager)

         guard centralManager.state == .poweredOn else {
            state = .poweredOff
            return
        }

        targetServiceUUIDs = serviceUUIDs ?? []

        DispatchQueue.main.async{
            self.isScanning = true
        }

        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false,
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ]

        centralManager.scanForPeripherals(
            withServices: targetServiceUUIDs,
            options: options
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + scanTimeout) { [weak self] in
            self?.stopScanning()
        }

        print("Started scanning...")
    }

    //MARK: - Stop scan
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

    //MARK: - Connect
    func connect(to device: Device) {
        stopScanning()
        state = .connecting

        guard let connectPeripheral = device.peripheral else {
            state = .poweredOn
            print("Peripheral not found.")
            return
        }
        centralManager.connect(connectPeripheral, options: nil)

        setConnectingDevice(connectPeripheral)

        print("Trying to connect to \(device.name)...")
    }

    //MARK: - Disconnect
    func disconnect(from device: Device) {
        guard let disconnectPeripheral = device.peripheral else { return }
        centralManager.cancelPeripheralConnection(disconnectPeripheral)

        print("Disconnecting from peripheral ")
    }

    //MARK: - Write
    func writeData(_ data: Data, to characteristicUUID: CBUUID) {
        guard let peripheral = connectedDevice,
              let characteristic = characteristics[characteristicUUID] else {
            print("Cannot write: peripheral or characteristic not available.")
            return
        }

        let writeType: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse

        guard let writePeripheral = peripheral.peripheral else {
            print("Cannot write: peripheral not available.")
            return
        }
        writePeripheral.writeValue(data, for: characteristic, type: writeType)
        print("Write data for characteristic: \(characteristicUUID)")
    }

    //MARK: - Read
    func readValue(for characteristicUUID: CBUUID) {
        guard let peripheral = connectedDevice?.peripheral,
              let characteristic = characteristics[characteristicUUID] else {
            print("Cannot read: peripheral or characteristic not available.")
            return
        }
        
        peripheral.readValue(for: characteristic)
        print("Read value for characteristic: \(characteristicUUID)")
    }

    //MARK: - Reset
    func resetConnection(){
        connectedPeripheral = nil
        connectedDevice = nil
        characteristics.removeAll()
        stopScanning()
    }
}

//MARK: - EXT CBCENTRALMANAGERDELEGATE
extension CBServiceManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            switch central.state {
                case .unknown:
                    self.state = .unknown
                case .resetting:
                    self.state = .resetting
                case .unsupported:
                    self.state = .unsupported
                case .unauthorized:
                    self.state = .unauthorized
                case .poweredOff:
                    self.state = .poweredOff
                case .poweredOn:
                    self.state = .poweredOn
                @unknown default:
                    self.state = .unknown
            }
        }
        print("Central Manager State changed to: \(central.state.rawValue) -> \(state)")
    }

    //MARK: - Discover Device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Peripheral"

        if deviceName.isEmpty || deviceName == "Unknown Name" {
            return
        }

        let device = Device(
            uid: peripheral.identifier.uuidString,
            peripheral: peripheral,
            name: peripheral.name ?? "Unknown Name",
            advertisementData: Device.advDataConverter(advertisementData),
            services: [],
            rssi: RSSI.intValue
        )

        let checkDuplicates = discoveredDevices.contains(where: { $0.peripheral?.name == peripheral.name && $0.uid.uuidString == peripheral.identifier.uuidString })

        if !checkDuplicates {
            discoveredDevices.append(device)
            print("Device found \(deviceName)")
            print("With RSSI: \(RSSI.intValue)")
            print("Peripheral Adv Data:")
            dump(device.advertisementData)
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

        setConnectingDevice(peripheral)
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
        removeConnectedDevice(peripheral)
    }
}

//MARK: - EXT CBPERIPHERALDELEGATE
extension CBServiceManager: CBPeripheralDelegate {
    //MARK: - Services found
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            state = .error(error!.localizedDescription)
            return
        }

        guard let services = peripheral.services else {
            print("Peripheral services array is nil")
            state = .error("Peripheral services array is nil")
            return
        }

        print("Discovered services for \(peripheral.name ?? "Unnamed peripheral")")

        setConnectedDevice(peripheral)
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

        setConnectedCharacteristicForService(peripheral, service)
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

        updateConnectedCharacteristicForService(peripheral, characteristic)
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

//MARK: - EXT Manage Connected Device
extension CBServiceManager {
    func setConnectingDevice(_ peripheral: CBPeripheral) {
        let connectingDevice = discoveredDevices.first(where: {$0.uid == peripheral.identifier})
        if let connectingDevice = connectingDevice {
            connectingDevice.connecting = true
            connectingDevice.connected = false
        }
    }

    func setConnectedDevice(_ peripheral: CBPeripheral) {
        connectedDevice = discoveredDevices.first(where: {$0.uid == peripheral.identifier})
        if let connectedDevice = connectedDevice {
            connectedDevice.connecting = false
            connectedDevice.connected = true
        }
    }

    func removeConnectedDevice(_ peripheral: CBPeripheral) {
        connectedDevice = discoveredDevices.first(where: {$0.uid == peripheral.identifier})
        if let connectedDevice = connectedDevice {
            connectedDevice.connecting = false
            connectedDevice.connected = false
        }
        connectedDevice = nil
        connectedPeripheral = nil
    }

    func setConnectedDeviceServices(_ peripheral: CBPeripheral) {
        if let foundServicesForDevice = peripheral.services {
            connectedDevice?.services = foundServicesForDevice
        }
    }

    func setConnectedCharacteristicForService(_ peripheral: CBPeripheral, _ service: CBService) {
        if let connectedServices = connectedDevice?.services {
            for var connectedService in connectedServices {
                if connectedService.uuid == service.uuid {
                    connectedService = service
                }
            }
        }
    }

    func updateConnectedCharacteristicForService(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        if let connectedServices = connectedDevice?.services {
            for connectedService in connectedServices {
                if connectedService.uuid == characteristic.service?.uuid {
                    for var connectedCharacteristic in connectedService.characteristics ?? [] {
                        if connectedCharacteristic.uuid == characteristic.uuid {
                            connectedCharacteristic = characteristic
                        }
                    }
                }
            }
        }
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
