//
//  CluetoothTests.swift
//  CluetoothTests
//
//  Created by Edu Caubilla on 2/9/25.
//

import XCTest
import Combine
@testable import Cluetooth
import CoreBluetooth

class MainViewModelTests: XCTestCase {
    //MARK: - PROPERTIES
    var sut: MainViewModel!
    var mockBluetoothManager: MockCBServiceManager!

    //MARK: - TEST CONFIG
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockBluetoothManager = MockCBServiceManager()
        sut = MainViewModel(bluetoothManager: mockBluetoothManager)
    }

    override func tearDownWithError() throws {
        mockBluetoothManager.resetAll()
        mockBluetoothManager = nil
        sut = nil
        try super.tearDownWithError()
    }

    //MARK: - TESTS
    //MARK: - Initial State
    func test_initialState_shouldInitializePropertiesWithDefaultValues() {
        XCTAssertTrue(sut.foundDevices.isEmpty, "Expected empty list of devices")
        XCTAssertNil(sut.linkedDevice, "Expected 'nil' linked device")
        XCTAssertEqual(sut.connectionStatus, "Disconnected", "Expected 'Disconnected' status")
        XCTAssertFalse(sut.isScanning, "Expected 'false' scanning status")
        XCTAssertFalse(sut.showConnectionTimedOutAlert, "Expected 'false' connection timeout alert")
    }

    //MARK: - Fetch devices
    func test_fetchDevices_whenScanning_shouldCallBluetoothManagerToScan() async {

        await sut.fetchDevices()

        XCTAssertEqual(mockBluetoothManager.startScanningCount, 1, "Expected BluetoothManager to start scanning")
        XCTAssertTrue(sut.isScanning)
        XCTAssertEqual(sut.connectionStatus, "Scanning...")
    }

    //MARK: - Connections
    func test_connectToDevice_whenNotScanning_shouldCallBluetoothManagerToConnect() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)

        sut.connectDevice(device1)

        XCTAssertEqual(mockBluetoothManager.connectCallCount, 1, "Expected BluetoothManager to connect")
        XCTAssertEqual(mockBluetoothManager.lastConnectedDevice, device1, "Expected BluetoothManager to connect to the provided device")
        XCTAssertEqual(mockBluetoothManager.state, .connecting, "Expected BluetoothManager to be in connecting state")
        XCTAssertEqual(sut.linkedDevice?.uid, device1.uid, "Expected ViewModel to link the connected device")
    }

    func test_connectToDevice_whenScanning_shouldEndScanningAndConnect() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)
        sut.isScanning = true

        sut.connectDevice(device1)

        XCTAssertEqual(mockBluetoothManager.isScanning, false, "Expected BluetoothManager to stop scanning")
        XCTAssertEqual(mockBluetoothManager.connectCallCount, 1, "Expected BluetoothManager to connect")
        XCTAssertEqual(mockBluetoothManager.lastConnectedDevice, device1, "Expected BluetoothManager to connect to the provided device")
        XCTAssertEqual(mockBluetoothManager.state, .connecting, "Expected BluetoothManager to be in connecting state")
    }

    func test_connectToDevice_WhenNotScanning_shouldSetLinkedDeviceAndReorderList() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)
        let device2 = Device(peripheral: nil, name: "Test Device 2", advertisementData: [:], services: [], rssi: 0, timestamp: nil)

        mockBluetoothManager.simulateDeviceDiscovered(device1)
        mockBluetoothManager.simulateDeviceDiscovered(device2)
        sut.connectDevice(device1)

        XCTAssertEqual(mockBluetoothManager.connectCallCount, 1, "Expected BluetoothManager to connect")
        XCTAssertEqual(sut.linkedDevice, device1, "Expected BluetoothManager to set linkedDevice")
        XCTAssertEqual(sut.foundDevices.first, device1, "Expected list to be reordered with linked device at the top")
        XCTAssertEqual(sut.foundDevices.last, device2, "Expected list to be reordered with not linked devices at the bottom")
    }

    func test_disconnectDevice_WhenLinked_shouldSetLinkedDeviceToNilAndReorderList() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)
        let device2 = Device(peripheral: nil, name: "Test Device 2", advertisementData: [:], services: [], rssi: 0, timestamp: nil)

        mockBluetoothManager.simulateDeviceDiscovered(device1)
        mockBluetoothManager.simulateDeviceDiscovered(device2)
        sut.linkedDevice = device1

        sut.disconnectDevice()

        XCTAssertEqual(mockBluetoothManager.disconnectCallCount, 1, "Expected BluetoothManager to disconnect")
        XCTAssertEqual(mockBluetoothManager.lastDisconnectedDevice, device1, "Expected BluetoothManager to disconnect the correct device")
        XCTAssertEqual(mockBluetoothManager.state, .disconnected, "Expected BluetoothManager to update to disconnected state")
        XCTAssertNil(sut.linkedDevice, "Expected BluetoothManager to set linkedDevice to nil")
        XCTAssertFalse(sut.foundDevices.first?.connected ?? true, "Expected the first device in the list to not be connected")
    }

    func test_disconnectDevice_WhenConnectTimedOutError_shouldDisconnectAndShowalertMessage() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)

        sut.linkedDevice = device1

        mockBluetoothManager.disconnect(from: device1, withError: true)

        XCTAssertEqual(mockBluetoothManager.disconnectCallCount, 1, "Expected BluetoothManager to disconnect")
        XCTAssertEqual(mockBluetoothManager.lastDisconnectedDevice, device1, "Expected BluetoothManager to disconnect the correct device")
        XCTAssertEqual(mockBluetoothManager.state, .error("Connection timed out."), "Expected BluetoothManager to update to error state")
        XCTAssertEqual(sut.linkedDevice, nil, "Expected the linked device to be nil")
        XCTAssertEqual(sut.showConnectionTimedOutAlert, true, "Expected the alert to be shown")

    }

    //MARK: - Other
    func test_toggleDeviceExpanded_WhenDeviceIsExpanded_shouldCollapseDevice() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)

        device1.expanded = true
        mockBluetoothManager.simulateDeviceDiscovered(device1)
        sut.linkedDevice = device1
        
        sut.toggleDeviceExpanded(uuid: device1.uid)

        XCTAssertFalse(sut.foundDevices.first!.expanded, "Expected the device to not be expanded")
    }

    func test_resetList_WhenScanning_ShouldResetDeviceList() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)
        let device2 = Device(peripheral: nil, name: "Test Device 2", advertisementData: [:], services: [], rssi: 0, timestamp: nil)

        mockBluetoothManager.simulateDeviceDiscovered(device1)
        mockBluetoothManager.simulateDeviceDiscovered(device2)
        mockBluetoothManager.startScanning(for: [])

        sut.resetList()

        XCTAssertEqual(mockBluetoothManager.resetListCallCount, 1, "Expected 'resetList' to be called once")
        XCTAssertFalse(sut.isScanning, "Expected 'false' scanning status")
        XCTAssertTrue(sut.foundDevices.isEmpty, "Expected an empty array of found devices")
    }

    func test_resetList_WhenNotScanning_ShouldResetDeviceList() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)
        let device2 = Device(peripheral: nil, name: "Test Device 2", advertisementData: [:], services: [], rssi: 0, timestamp: nil)

        mockBluetoothManager.simulateDeviceDiscovered(device1)
        mockBluetoothManager.simulateDeviceDiscovered(device2)

        sut.resetList()

        XCTAssertEqual(mockBluetoothManager.resetListCallCount, 1, "Expected 'resetList' to be called once")
        XCTAssertTrue(sut.foundDevices.isEmpty, "Expected an empty array of found devices")
    }


    func test_restartScan_ShouldResetDataAndStartScanning() {
        let device1 = Device(peripheral: nil, name: "Test Device 1", advertisementData: [:], services: [], rssi: 0, timestamp: nil)
        let device2 = Device(peripheral: nil, name: "Test Device 2", advertisementData: [:], services: [], rssi: 0, timestamp: nil)

        mockBluetoothManager.simulateDeviceDiscovered(device1)
        mockBluetoothManager.simulateDeviceDiscovered(device2)

        let expectation = XCTestExpectation(description: "Scan started")

        sut.restartScan()

        DispatchQueue.main.async {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(mockBluetoothManager.resetListCallCount, 1, "Expected 'resetList' to be called once")
        XCTAssertTrue(sut.foundDevices.isEmpty, "Expected an empty array of found devices")
        XCTAssertEqual(mockBluetoothManager.startScanningCount, 1, "Expected BluetoothManager to start scanning")
        XCTAssertTrue(sut.isScanning, "Expected 'isScanning' to be true")
        XCTAssertEqual(sut.connectionStatus, "Scanning...", "Expected 'connectionStatus' to be 'Scanning...'")
    }
}
