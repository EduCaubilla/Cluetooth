//
//  MainViewModel.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 3/9/25.
//

import SwiftUI
import SwiftData
import CoreBluetooth

class MainViewModel: ObservableObject {
    //MARK: - PROPERTIES
    @Environment(\.modelContext) private var modelContext

    let bluetoothManager : CBServiceManager?

    @Published var savedDevices: [Device] = []
    @Published var foundDevices: [Device] = []
    @Published var linkedDevice: Device?
    @Published var connectionStatus: String = "Disconnected"
    @Published var isScanning: Bool = false

    //MARK: - INITIALIZER
    init(bluetoothManager: CBServiceManager = CBServiceManager.shared) {
        self.bluetoothManager = bluetoothManager
        setupStates()
        setupObservers()
    }

    //MARK: - FUNCTIONS
    func setupStates() {
        bluetoothManager?.$state
            .map { state in
                switch state {
                    case .connected:
                        return "Connected"
                    case .connecting:
                        return "Connecting..."
                    case .scanning:
                        return "Scanning..."
                    case .disconnected:
                        return "Disconnected"
                    case .error(let message):
                        return "Error: \(message)"
                    default:
                        return "Ready"
                }
            }
            .assign(to: &$connectionStatus)
    }

    func setupObservers() {
        // Observe discovered devices
        bluetoothManager?.$discoveredDevices
            .assign(to: &$foundDevices)

        // Observe connected devices
        bluetoothManager?.$connectedDevice.assign(to: &$linkedDevice)

        // Observe scanning state
        bluetoothManager?.$isScanning.assign(to: &$isScanning)
    }

    func fetchDevices() async {
        bluetoothManager?.startScanning()
    }

    func connectDevice(_ device: Device) {
        disconnectDevice()

        print("Connecting Device: \(device.name)")
        bluetoothManager?.connect(to: device)

        let connectedDevice = foundDevices.first(where: { $0.uid == device.uid })
        connectedDevice?.connecting = true

        foundDevices = foundDevices.sorted { $0.connecting && !$1.connecting }

        linkedDevice = device
    }


    func disconnectDevice() {
        if linkedDevice != nil {
            bluetoothManager?.disconnect(from: linkedDevice!)
        }

        _ = foundDevices.map { $0.connected = false }
    }

    func removeFoundDevice(_ device: Device) {
        print("Remove Device: \(device.name)")
        foundDevices.remove(at: foundDevices.firstIndex(of: device)!)
    }

    func toggleDeviceExpanded(uuid: UUID) {
        if let index = foundDevices.firstIndex(where: { $0.uid == uuid }) {
            foundDevices[index].expanded.toggle()
            foundDevices = foundDevices

            print("Toggle expand for \(foundDevices[index].name) to \(foundDevices[index].expanded)")
        }
    }
}
