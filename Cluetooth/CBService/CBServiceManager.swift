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

    @Published private(set) var state: BluetoothState = .disconnected
    @Published private(set) var discoveredDevices: [Device] = []
    @Published var connectedDevice: Device?
    @Published private(set) var isScanning: Bool = false

    var statePublisher: Published<BluetoothState>.Publisher { $state }
    var discoveredDevicesPublisher: Published<[Device]>.Publisher { $discoveredDevices }
    var connectedDevicePublisher: Published<Device?>.Publisher { $connectedDevice }
    var isScanningPublisher: Published<Bool>.Publisher { $isScanning }

    private var centralManager: CBCentralManager
    private let peripheralManager: CBPeripheralManager

    var connectedPeripheral: CBPeripheral?
    var targetServiceUUIDs: [CBUUID] = []
    var characteristics: [CBUUID: CBCharacteristic] = [:]

    private let scanTimeout: TimeInterval = 10.0
    private var scanTimer: Timer?

    let connectionTimeout: TimeInterval = 10.0
    var connectionTimer: Timer?

    private let maxDiscoveredDevices: Int = 3

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
            AppLogger.warning("Bluetooth is off, can't start scanning", category: "app")
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

        DispatchQueue.main.async{
            self.scanTimer = Timer.scheduledTimer(withTimeInterval: self.scanTimeout, repeats: false, block: { [weak self] _ in
                self?.stopScanning()
            })
        }

        AppLogger.info("Started scanning...")
    }

    //MARK: - Stop scan
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        scanTimer?.invalidate()
        scanTimer = nil

        if state == .scanning {
            updateState(.poweredOn)
        }

        AppLogger.info("Discovered devices: \(discoveredDevices.count).")
        AppLogger.info("Stopped scanning.")
    }

    //MARK: - Connect
    func connect(to device: Device) {
        guard let connectPeripheral = device.peripheral else {
            state = .poweredOn
            AppLogger.warning("Peripheral not found.")
            return
        }

        if isScanning {
            stopScanning()
        }

        updateState(.connecting)
        setDeviceConnectionState(connectPeripheral, connecting: true, connected: false)

        centralManager.connect(connectPeripheral, options: [
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ])

        DispatchQueue.main.async {
            AppLogger.info("Connection Timer Started.")
            self.connectionTimer = Timer.scheduledTimer(withTimeInterval: self.connectionTimeout, repeats: false, block: { [weak self] _ in
                AppLogger.info("Connection Timer Ended.")
                self?.disconnect(from: device, withError: true)
            })
        }

        AppLogger.info("Trying to connect to \(device.name)...")
    }

    //MARK: - Disconnect
    func disconnect(from device: Device, withError: Bool) {
        if withError {
            guard state == .connecting else { return }
            connectionTimer?.invalidate()
            connectionTimer = nil
            updateState(.error("Connection timed out."))
        }

        disconnect(from: device)
    }

    func disconnect(from device: Device) {
        guard let disconnectPeripheral = device.peripheral else {
            AppLogger.warning("Cannot disconnect: \(device.name) not found.")
            return
        }

        centralManager.cancelPeripheralConnection(disconnectPeripheral)

        setDeviceConnectionState(disconnectPeripheral, connecting: false, connected: false)

        AppLogger.info("Disconnecting from \(device.name).")
    }

    //MARK: - Write
    func writeData(_ data: Data, to characteristicUUID: CBUUID) {
        guard let peripheral = connectedDevice?.peripheral,
              let characteristic = characteristics[characteristicUUID] else {
            AppLogger.warning("Cannot write: peripheral or characteristic not available.")
            return
        }

        let writeType: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse

        peripheral.writeValue(data, for: characteristic, type: writeType)
        AppLogger.info("Writing data for characteristic: \(characteristicUUID).")
    }

    //MARK: - Read
    func readValue(for characteristicUUID: CBUUID) {
        guard let peripheral = connectedDevice?.peripheral,
              let characteristic = characteristics[characteristicUUID] else {
            AppLogger.warning("Cannot read: peripheral or characteristic not available.")
            return
        }
        
        peripheral.readValue(for: characteristic)
        AppLogger.info("Reading value for characteristic: \(characteristicUUID).")
    }

    //MARK: - Reset
    func resetConnection(){
        connectedPeripheral = nil
        connectedDevice = nil
        characteristics.removeAll()

        if isScanning {
            stopScanning()
        }

        AppLogger.info("Device Connection Reset.")
    }

    func resetList(){
        discoveredDevices.removeAll()
        AppLogger.info("Device Main List Reset.")
    }

    //MARK: - Helpers
    func updateState(_ newState: BluetoothState) {
        DispatchQueue.main.async {
            self.state = newState
        }
        AppLogger.info("Bluetooth state updated to \(state)")
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
