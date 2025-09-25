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
    let bluetoothManager : (any CBServiceManagerProtocol)?

    @Published var foundDevices: [Device] = []
    @Published var linkedDevice: Device?
    @Published var connectionStatus: String = "Disconnected"
    @Published var isScanning: Bool = false
    @Published var showConnectionTimedOutAlert: Bool = false

    //MARK: - INITIALIZER
    init(bluetoothManager: any CBServiceManagerProtocol = CBServiceManager.shared) {
        self.bluetoothManager = bluetoothManager
        setupStates()
        setupObservers()
    }

    //MARK: - FUNCTIONS
    func setupStates() {
        bluetoothManager?.statePublisher
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
                        self.checkMessageForAlert(message)
                        return "Error: \(message)"
                    default:
                        return "Ready"
                }
            }
            .assign(to: &$connectionStatus)
    }

    func setupObservers() {
        // Observe discovered devices
        bluetoothManager?.discoveredDevicesPublisher
            .assign(to: &$foundDevices)

        // Observe connected devices
        bluetoothManager?.connectedDevicePublisher.assign(to: &$linkedDevice)

        // Observe scanning state
        bluetoothManager?.isScanningPublisher.assign(to: &$isScanning)
    }

    func fetchDevices() async {
        bluetoothManager?.startScanning(for: [])
    }

    func connectDevice(_ device: Device) {
        disconnectDevice()

        if device.expanded {
            device.expanded.toggle()
        }

        AppLogger.info("Call to connect device: \(device.name)", category: "ui")
        bluetoothManager?.connect(to: device)

        foundDevices = foundDevices.sorted { $0.connecting && !$1.connecting }
    }

    func disconnectDevice() {
        if linkedDevice != nil {
            AppLogger.info("Call to disconnect device: \(linkedDevice?.name ?? "Unknown name")", category: "ui")
            bluetoothManager?.disconnect(from: linkedDevice!, withError: false)
        }

        _ = foundDevices.map { $0.connected = false }
    }

    func toggleDeviceExpanded(uuid: UUID) {
        if let index = foundDevices.firstIndex(where: { $0.uid == uuid }) {
            foundDevices[index].expanded.toggle()
            foundDevices = foundDevices
        }
    }

    func checkMessageForAlert(_ message: String) {
        if message == "Connection timed out." {
            showConnectionTimedOutAlert = true
        }
    }

    func resetList() {
        bluetoothManager?.stopScanning()
        bluetoothManager?.resetList()
    }

    func restartScan() {
        resetList()
        Task {
            await fetchDevices()
        }
        AppLogger.info("Restart scan", category: "ui")
    }
}
