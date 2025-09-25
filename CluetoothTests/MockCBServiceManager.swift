//
//  MockCBServiceManager.swift
//  CluetoothTests
//
//  Created by Edu Caubilla on 23/9/25.
//

import Foundation
import XCTest
@testable import Cluetooth
import CoreBluetooth

class MockCBServiceManager: CBServiceManagerProtocol, ObservableObject {
    //MARK: - PROPERTIES
    @Published private(set) var state: BluetoothState = .disconnected
    @Published private(set) var discoveredDevices: [Device] = []
    @Published var connectedDevice: Device?
    @Published private(set) var isScanning: Bool = false

    var statePublisher: Published<Cluetooth.BluetoothState>.Publisher { $state }
    var discoveredDevicesPublisher: Published<[Cluetooth.Device]>.Publisher { $discoveredDevices }
    var connectedDevicePublisher: Published<Cluetooth.Device?>.Publisher { $connectedDevice }
    var isScanningPublisher: Published<Bool>.Publisher { $isScanning }

    var startScanningCount: Int = 0
    var stopScanningCount: Int = 0
    var connectCallCount: Int = 0
    var disconnectCallCount: Int = 0
    var writeDataCallCount: Int = 0
    var readValueCallCount: Int = 0
    var resetConnectionCallCount: Int = 0
    var resetListCallCount: Int = 0

    var lastConnectedDevice: Device?
    var lastDisconnectedDevice: Device?
    var lastServiceUUIDs: [CBUUID]?

    //MARK: - FUNCTIONS
    func startScanning(for serviceUUIDs: [CBUUID]?) {
        startScanningCount += 1
        lastServiceUUIDs = serviceUUIDs
        isScanning = true
        state = .scanning
    }
    
    func stopScanning() {
        stopScanningCount += 1
        isScanning = false
        if state == .scanning {
            updateState(.poweredOn)
        }
    }
    
    func connect(to device: Cluetooth.Device) {
        connectCallCount += 1
        lastConnectedDevice = device

        if isScanning {
            stopScanning()
        }

        updateState(.connecting)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.connectedDevice = device
            self.updateState(.connected)
        }
    }
    
    func disconnect(from device: Cluetooth.Device, withError: Bool) {
        disconnectCallCount += 1

        if withError {
            updateState(.error("Connection timed out."))
        } else {
            updateState(.disconnected)
        }

        lastDisconnectedDevice = device
        connectedDevice = nil
    }
    
    func writeData(_ data: Data, to characteristicUUID: CBUUID) {
        writeDataCallCount += 1
    }
    
    func readValue(for characteristicUUID: CBUUID) {
        readValueCallCount += 1
    }
    
    func resetConnection() {
        resetConnectionCallCount += 1
        connectedDevice = nil
        if isScanning {
            stopScanning()
        }
    }
    
    func resetList() {
        resetListCallCount += 1
        discoveredDevices = []
    }

    //MARK: - Helpers
    func updateState(_ state: BluetoothState) {
        self.state = state
    }

    func simulateDeviceDiscovered(_ device: Device) {
        discoveredDevices.append(device)
    }

    func simulateBluetoothOff() {
        state = .poweredOff
        isScanning = false
    }

    func resetAll() {
        startScanningCount = 0
        stopScanningCount = 0
        connectCallCount = 0
        disconnectCallCount = 0
        writeDataCallCount = 0
        readValueCallCount = 0
        resetConnectionCallCount = 0
        resetListCallCount = 0
        lastConnectedDevice = nil
        lastDisconnectedDevice = nil
        lastServiceUUIDs = []
        state = .unknown
        isScanning = false
        connectedDevice = nil
        discoveredDevices = []
    }
}
