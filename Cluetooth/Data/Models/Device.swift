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
final class Device: Equatable {
    @Attribute(.unique) var uid: UUID
    var peripheral: CBPeripheral
    var name: String
    @Relationship(deleteRule: .cascade) var services : [String: Any] = [:]
    var rssi: Int
    var timestamp: Date?

    init(peripheral: CBPeripheral, name: String, services: [String: Any], rssi: Int) {
        self.uid = UUID()
        self.peripheral = peripheral
        self.name = name
        self.services = services
        self.rssi = rssi
        self.timestamp = timestamp ?? Date.now
    }
}
