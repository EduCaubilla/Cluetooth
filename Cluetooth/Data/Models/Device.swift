//
//  Item.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import Foundation
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

    var id: String { uid.uuidString }

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
