//
//  ServiceAdvertisementDataKey.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 18/9/25.
//

import Foundation

enum ServiceAdvertisementDataKey: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case CBAdvertisementDataServiceData = "kCBAdvDataServiceData"
    case CBAdvertisementDataServiceUUIDs = "kCBAdvDataServiceUUIDs"
    case CBAdvertisementDataOverflowServiceUUIDs = "kCBAdvDataOverflowServiceUUIDs"
    case CBAdvertisementDataTxPowerLevel = "kCBAdvDataTxPowerLevel"
    case CBAdvertisementDataIsConnectable = "kCBAdvDataIsConnectable"
    case CBAdvertisementDataLocalNameKey = "kCBAdvDataLocalNameKey"
    case CBAdvertisementDataManufacturerData = "kCBAdvDataManufacturerData"
    case CBAdvertisementDataSolicitedServiceUUIDs = "kCBAdvDataSolicitedServiceUUIDs"
    case CBAdvertisementDataRxPrimaryPHY = "kCBAdvDataRxPrimaryPHY"
    case CBAdvertisementDataRxSecondaryPHY = "kCBAdvDataRxSecondaryPHY"
    case CBAdvertisementDataTimestamp = "kCBAdvDataTimestamp"

    var displayName: String {
        switch self {
            case .CBAdvertisementDataServiceData:
                return "Service Data"
            case .CBAdvertisementDataServiceUUIDs:
                return "Service Information Available"
            case .CBAdvertisementDataOverflowServiceUUIDs:
                return "Additional Service Information Available"
            case .CBAdvertisementDataTxPowerLevel:
                return "Transmit power level"
            case .CBAdvertisementDataIsConnectable:
                return "Device is connectable"
            case .CBAdvertisementDataLocalNameKey:
                return "Device name"
            case .CBAdvertisementDataManufacturerData:
                return "Manufacturer data"
            case .CBAdvertisementDataSolicitedServiceUUIDs:
                return "Solicited services UUIDs"
            case .CBAdvertisementDataRxPrimaryPHY:
                return "Physical Layer LE 1M Support"
            case .CBAdvertisementDataRxSecondaryPHY:
                return "Physical Layer LE 2M Support"
            case .CBAdvertisementDataTimestamp:
                return "Device Timestamp (Date)"
        }
    }

    static func getDescription(for key: String) -> String? {
        self.allCases.first(where: { $0.rawValue == key })?.displayName
    }

    static func setCase(for value: String) -> ServiceAdvertisementDataKey? {
        .allCases.first(where: { $0.rawValue == value })
    }
}
