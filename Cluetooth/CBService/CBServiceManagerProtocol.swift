//
//  CBServiceManagerProtocol.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 3/9/25.
//

import Foundation
import CoreBluetooth

protocol CBServiceManagerProtocol: ObservableObject {
    var state: BluetoothState { get }
    var discoveredDevices: [Device] { get }
    var connectedDevice: Device? { get }
    var isScanning: Bool { get }

    var statePublisher: Published<BluetoothState>.Publisher { get }
    var discoveredDevicesPublisher: Published<[Device]>.Publisher { get }
    var connectedDevicePublisher: Published<Device?>.Publisher { get }
    var isScanningPublisher: Published<Bool>.Publisher { get }

    func startScanning(for serviceUUIDs: [CBUUID]?)
    func stopScanning()
    func connect(to device: Device)
    func disconnect(from device: Device, withError: Bool)
    func writeData(_ data: Data, to characteristicUUID: CBUUID)
    func readValue(for characteristicUUID: CBUUID)
    func resetConnection()
    func resetList()
}
