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

        // Observe discovered devices
        bluetoothManager?.$discoveredDevices
            .assign(to: &$foundDevices)

        // Observe connected devices
        bluetoothManager?.$connectedDevice.assign(to: &$linkedDevice)

        // Observe scanning state
        bluetoothManager?.$isScanning.assign(to: &$isScanning)
    }

    func fetchDevices() async {
        print("Fetch devices..")
//        guard let bluetoothManager = bluetoothManager else { return }
//
//        let discoveredDevices = await withCheckedContinuation { (continuation: CheckedContinuation<[Device], Never>) in
//            bluetoothManager.onScanFinished = { devices in
//                continuation.resume(returning: devices)
//            }
//            bluetoothManager.startScanning()
//        }
//        await setFoundDevices(discoveredDevices)

        bluetoothManager?.startScanning()
    }

//    @MainActor
//    private func setFoundDevices(_ devices: [Device]) {
//        print("Devices passed: \(devices.count)")
//        foundDevices = devices.filter { devices.contains($0) == false }
//
//        print("Devices ready: \(foundDevices.count)")
//    }

    func connectDevice(_ device: Device) {
        if linkedDevice != nil {
            bluetoothManager?.disconnect(from: linkedDevice!)
        }

        print("Connect Device: \(device.name)")
        bluetoothManager?.connect(to: device)

        let connectedDevice = foundDevices.first(where: { $0.uid == device.uid })
        connectedDevice?.connected = true

        foundDevices = foundDevices.sorted { $0.connected && !$1.connected }

        linkedDevice = device
    }

    func removeFoundDevice(_ device: Device) {
        print("Remove Device: \(device.name)")
        foundDevices.remove(at: foundDevices.firstIndex(of: device)!)
    }

    //MARK: - SWIFT DATA
    private func addItem(uid: String, peripheral: CBPeripheral, name: String, services: [String: String], rssi: Int) {
        withAnimation {
            let newDevice = Device(
                uid: uid,
                peripheral: peripheral,
                name: name,
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
