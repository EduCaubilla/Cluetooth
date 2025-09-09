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

extension Device {
    static func advDataConverter(_ advData: [String : Any]) -> [String: String] {
        var responseData : [String: String] = [:]

        advData.forEach{ key, value in
            let responseKey = ServiceAdvertisementDataKey.getDescription(for: key)
            let enumKeyValue = ServiceAdvertisementDataKey.setCase(for: key)
            let responseValue = getServiceValueMapped(for: enumKeyValue ?? nil, with: "\(value)")
            responseData[responseKey ?? ""] = responseValue
        }

        return responseData
    }

//    static func serviceConverter(for data: [CBService], with key: String) {
//        var convertedData: [String: String] = [:]
//        
//        for service in data {
//            let key = getKeyDescription(for: key)
//            let value = BluetoothUUIDMapper.getServiceDescription(for: service.uuid)
//            convertedData[key] = value
//        }
//    }
}

extension Device {
    static func getServiceValueMapped(for adv:ServiceAdvertisementDataKey?, with inputValue: Any) -> String {
        switch adv {
            case .CBAdvertisementDataLocalNameKey, .CBAdvertisementDataServiceData:
                return inputValue as? String ?? "Unkown" // String

            case .CBAdvertisementDataTxPowerLevel:
                return inputValue as? String ?? "0" // Int

            case .CBAdvertisementDataServiceUUIDs, .CBAdvertisementDataOverflowServiceUUIDs, .CBAdvertisementDataSolicitedServiceUUIDs:
                var response: String = ""
                let uuidsArray = inputValue as? [CBUUID] // [UUID]
                if let uuidsArray = uuidsArray {
                    uuidsArray.forEach { uuid in
                        response.append(BluetoothUUIDMapper.getServiceDescription(for: uuid))
                    }
                }
                return response

            case .CBAdvertisementDataIsConnectable, .CBAdvertisementDataRxPrimaryPHY, .CBAdvertisementDataRxSecondaryPHY:
                return boolToDescription(mapToBool(inputValue as? String ?? "0")) // Bool

            case .CBAdvertisementDataManufacturerData:
                return String(data: inputValue as? Data ?? Data(), encoding: String.Encoding.utf8) ?? "None" //NSData

            case .CBAdvertisementDataTimestamp:
                let timestamp: Double = NSString(string:"\(inputValue)").doubleValue
                return utils.timeStampToDate(timestamp) // Double

            default :
                return inputValue as? String ?? ""
        }
    }

    static func mapToBool(_ value: String) -> Bool {
        return value == "1"
    }

    static func boolToDescription(_ value: Bool) -> String {
        return value ? "Yes" : "No"
    }

    static func getKeyDescription(for key: String) -> String {
        var resultKey = ""
        ServiceAdvertisementDataKey.allCases.forEach { serviceKey in
            if serviceKey.id == key {
                resultKey = serviceKey.displayName
            }
        }
        return resultKey
    }
}

struct utils {
    static func stringListToArray(_ stringList: String) -> [String] {
        return stringList.split(separator: ",").map(String.init)
    }

    static func uuidsToStringArray(_ uuids: [String]) -> [String] {
        var serviceUUIDS: [String] = []
        uuids.forEach { uuid in
            serviceUUIDS = stringListToArray(uuid)
        }
        return serviceUUIDS
    }

//    static func uuidStringToDescription(_ uuid: String) -> String {
//        let btMapper = BluetoothUUIDMapper()
//        return ""
//    }

    static func timeStampToDate(_ timeStamp: Double) -> String {
        let date = Date(timeIntervalSinceReferenceDate: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss | dd MMM yyyy"
        return dateFormatter.string(from: date)
    }
}

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
