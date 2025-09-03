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

    @Query private var devices: [Device]

    //MARK: - INITIALIZER
    init() {
    }

    //MARK: - FUNCTIONS


    //MARK: - SWIFT DATA
    private func addItem(peripheral: CBPeripheral, name: String, uid: String, services: [String: Any], rssi: Int) {
        withAnimation {
            let newDevice = Device(peripheral: peripheral, name: name, services: services, rssi: rssi)
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

    //MARK: - CONNECTIONS
}
