//
//  DataConverter.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 10/9/25.
//

import Foundation

extension Data {
    init?(hexString: String) {
        let stringLength = hexString.count / 2
        var data = Data(capacity: stringLength)
        var i = hexString.startIndex
        for _ in 0..<stringLength {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }
}
