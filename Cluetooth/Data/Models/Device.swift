//
//  Item.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import SwiftUI
import SwiftData
import CoreBluetooth

@Model
final class Device: Equatable, Identifiable {
    @Attribute(.unique) var uid: UUID
    @Transient var peripheral: CBPeripheral? = nil
    var name: String
    @Relationship(deleteRule: .cascade) var services : [String: String]
    var rssi: Int
    var connected: Bool
    var timestamp: Date?
    var expanded: Bool = false

    var id: String { uid.uuidString }
    var signalStrengthColor: Color {
        switch rssi {
            case -50...0: return .green
            case -70..<(-50): return .yellow
            case -85..<(-70): return .orange
            default: return .red
        }
    }

    init(
        uid: String,
        peripheral: CBPeripheral,
        name: String,
        services: [String: String],
        rssi: Int
    ) {
        self.uid = UUID(uuidString: uid)!
        self.peripheral = peripheral
        self.name = name
        self.services = services
        self.rssi = rssi
        self.connected = false
        self.timestamp = timestamp ?? Date.now
    }
}
