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
    @Published var savedDevices: [Device] = []

    @Published var foundDevices: [Device] = []

    @Published var connectionStatus: String = "Disconnected"

    @Query private var devices: [Device]

    let bluetoothManager : CBServiceManager?

    var devicesReady: Bool { !foundDevices.isEmpty }

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

    //MARK: - SWIFT DATA
    private func addItem(peripheral: CBPeripheral, name: String, uid: String, services: [String: Any], rssi: Int) {
        withAnimation {
            let newDevice = Device(
                peripheral: peripheral,
                name: name,
//                services: services,
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
