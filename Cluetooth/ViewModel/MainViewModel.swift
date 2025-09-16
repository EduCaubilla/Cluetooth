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

    @Query private var devices: [Device]

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
        if linkedDevice != nil {
            bluetoothManager?.disconnect(from: linkedDevice!)
        }

        print("Connecting Device: \(device.name)")
        bluetoothManager?.connect(to: device)

        _ = foundDevices.map { $0.connected = false }

        let connectedDevice = foundDevices.first(where: { $0.uid == device.uid })
        connectedDevice?.connecting = true

        foundDevices = foundDevices.sorted { $0.connecting && !$1.connecting }

        linkedDevice = device
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

    //MARK: - SWIFT DATA
    private func addItem(uid: String, peripheral: CBPeripheral, name: String, advertisementData: [String: String], services: [CBService], rssi: Int) {
        withAnimation {
            let newDevice = Device(
                uid: uid,
                peripheral: peripheral,
                name: name,
                advertisementData: advertisementData,
                services: services,
                rssi: rssi
            )
            modelContext.insert(newDevice)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(devices[index])
            }
        }
    }
}
