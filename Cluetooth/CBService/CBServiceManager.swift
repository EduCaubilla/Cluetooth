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

    @Published private(set) var state: BluetoothState = .unknown
    @Published private(set) var discoveredDevices: [Device] = []
    @Published var connectedDevice: Device?
    @Published private(set) var isScanning: Bool = false

    private var centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    var connectedPeripheral: CBPeripheral?
    var targetServiceUUIDs: [CBUUID] = []
    var characteristics: [CBUUID: CBCharacteristic] = [:]

    private let scanTimeout: TimeInterval = 10.0
    private var scanTimer: Timer?
    private let maxDiscoveredDevices: Int = 30

    //MARK: - INITIALIZER
    override init() {
        peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        centralManager = CBCentralManager(delegate: nil, queue: nil)

        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    //MARK: - FUNCTIONS
    //MARK: - Scan
    func startScanning(for serviceUUIDs: [CBUUID]? = nil) {
        centralManagerDidUpdateState(centralManager)

         guard centralManager.state == .poweredOn else {
            updateState(.poweredOff)
            print("Bluetooth is off, can't start scanning")
            return
        }

        targetServiceUUIDs = serviceUUIDs ?? []

        DispatchQueue.main.async {
            self.isScanning = true
        }

        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
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
            updateState(.poweredOn)
        }

        print("Stopped scanning.")
    }

    //MARK: - Connect
    func connect(to device: Device) {
        guard let connectPeripheral = device.peripheral else {
            state = .poweredOn
            print("Peripheral not found.")
            return
        }

        stopScanning()
        updateState(.connecting)
        setDeviceConnectionState(connectPeripheral, connecting: true, connected: false)

        centralManager.connect(connectPeripheral, options: [
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ])

        print("Trying to connect to \(device.name)...")
    }

    //MARK: - Disconnect
    func disconnect(from device: Device) {
        guard let disconnectPeripheral = device.peripheral else {
            print("Cannot disconnect: peripheral not found.")
            return
        }

        centralManager.cancelPeripheralConnection(disconnectPeripheral)

        print("Disconnecting from peripheral ")
    }

    //MARK: - Write
    func writeData(_ data: Data, to characteristicUUID: CBUUID) {
        guard let peripheral = connectedDevice?.peripheral,
              let characteristic = characteristics[characteristicUUID] else {
            print("Cannot write: peripheral or characteristic not available.")
            return
        }

        let writeType: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse

        peripheral.writeValue(data, for: characteristic, type: writeType)
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
        print("Connection Reset")
    }

    //MARK: - Helpers
    func updateState(_ newState: BluetoothState) {
        DispatchQueue.main.async {
            self.state = newState
        }
    }

    func addOrUpdateDevice(_ device: Device) {
        if let currentIndex = discoveredDevices.firstIndex(where: { $0.uid == device.uid }) {
            discoveredDevices[currentIndex] = device
        } else {
            if discoveredDevices.count >= maxDiscoveredDevices {
                if let oldestIndex = discoveredDevices.enumerated()
                    .filter({ !$0.element.connected })
                    .min(by: { $0.element.rssi < $1.element.rssi })?.offset {
                    discoveredDevices.remove(at: oldestIndex)
                }
            }
            discoveredDevices.append(device)
        }

        sortDiscoveredDevices()
    }

    func sortDiscoveredDevices() {
        discoveredDevices.sort { (device1, device2) -> Bool in
            if device1.connected != device2.connected {
                return device1.connected
            }

            if (device1.name != "Unkown Name") != (device2.name != "Unkown Name") {
                return device1.name != "Unkown Name"
            }

            return device1.rssi > device2.rssi
        }
    }
}
