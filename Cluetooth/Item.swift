//
//  Item.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
