//
//  BluetoothState.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 19/9/25.
//

import Foundation

enum BluetoothState : Equatable {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    case scanning
    case connecting
    case connected
    case disconnected
    case error(String)
}
