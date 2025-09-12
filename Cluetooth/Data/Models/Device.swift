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
    var advertisementData : [String: String]
    @Transient var services : [CBService] = []
    @Transient var characteristics : [CBCharacteristic] = []
    var rssi: Int
    var connected: Bool
    @Transient var connecting: Bool = false
    var timestamp: Date?
    @Transient var expanded: Bool = false

    var id: String { uid.uuidString }
    var signalStrengthColor: Color {
        switch rssi {
            case -50...0: return .green
            case -70..<(-50): return .yellow
            case -85..<(-70): return .orange
            default: return .red
        }
    }

    init(uid: String,
        peripheral: CBPeripheral,
        name: String,
        advertisementData: [String: String],
        services: [CBService],
        rssi: Int) {
        self.uid = UUID(uuidString: uid)!
        self.peripheral = peripheral
        self.name = name
        self.advertisementData = advertisementData
        self.services = services
        self.rssi = rssi
        self.connected = false
        self.connecting = false
        self.timestamp = timestamp ?? Date.now
    }

    init(peripheral: CBPeripheral,
         advertisementData: [String: Any],
         services: [CBService],
         connected: Bool = false) {
        self.uid = UUID(uuidString: peripheral.identifier.uuidString)!
        self.peripheral = peripheral
        self.name = peripheral.name ?? "Unknown"
        self.advertisementData = Device.advDataConverter(advertisementData)
        self.services = services
        self.rssi = 0
        self.connected = connected
        self.connecting = false
    }
}

extension Device {
    static func advDataConverter(_ advData: [String : Any]) -> [String: String] {
        var responseData : [String: String] = [:]

        advData.forEach{ key, value in
            let responseKey = ServiceAdvertisementDataKey.getDescription(for: key)
            let enumKeyValue = ServiceAdvertisementDataKey.setCase(for: key)
            let responseValue = getAdvertisementValueMapped(for: enumKeyValue ?? nil, with: "\(value)")
            responseData[responseKey ?? ""] = responseValue
        }

        return responseData
    }

    static func serviceConverter(for data: [CBService]) -> [String: String] {
            var convertedData: [String: String] = [:]
    
            for service in data {
                let key = ""
                let value = BluetoothUUIDMapper.getServiceDescription(for: service.uuid)
                convertedData[key] = value
            }
            return convertedData
        }
}

extension Device {
    static func getAdvertisementValueMapped(for adv:ServiceAdvertisementDataKey?, with inputValue: Any) -> String {
        switch adv {
            case .CBAdvertisementDataLocalNameKey, .CBAdvertisementDataServiceData:
                return inputValue as? String ?? "Unkown" // String

            case .CBAdvertisementDataTxPowerLevel:
                return inputValue as? String ?? "0" // Int

            case .CBAdvertisementDataServiceUUIDs, .CBAdvertisementDataOverflowServiceUUIDs, .CBAdvertisementDataSolicitedServiceUUIDs:
                return dataServiceUUIDsConverter(for: inputValue as? String ?? "")

            case .CBAdvertisementDataIsConnectable, .CBAdvertisementDataRxPrimaryPHY, .CBAdvertisementDataRxSecondaryPHY:
                return boolToDescription(mapToBool(inputValue as? String ?? "0")) // Bool

            case .CBAdvertisementDataManufacturerData:
                var response = "No data"
                let stringHex =  utils.anyManufacturerDataToHexString(inputValue as? String ?? "")

                if let dataFromHex = Data(hexString: stringHex) {
                    response = BluetoothManufacturerMapper().parseManufacturerData(dataFromHex)!
                }

                return response

            case .CBAdvertisementDataTimestamp:
                let timestamp: Double = NSString(string:"\(inputValue)").doubleValue
                return utils.timeStampToDate(timestamp) // Double

            default :
                return inputValue as? String ?? ""
        }
    }

    static func boolToDescription(_ value: Bool) -> String {
        return value ? "Yes" : "No"
    }

    static func mapToBool(_ value: String) -> Bool {
        return value == "1"
    }

    static func dataServiceUUIDsConverter(for stringData: String) -> String {
        var result : String = ""
        var services : [String] = []

        let startIndex = stringData.firstIndex(of: " ")!
        let endIndex = stringData.lastIndex(of: ")")!

        if stringData.count > 0 {
            let stringsRaw = String(stringData[startIndex..<endIndex])
            let stringList = stringsRaw.split(separator: ",").map(String.init)
            stringList.forEach { string in
                let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanString = trimmedString.trimmingCharacters(in: .punctuationCharacters)
                if cleanString.count == 4 {
                    let description = BluetoothUUIDMapper.getServiceDescription(for: cleanString)
                    services.append(description)
                } else {
                    services.append(trimmedString)
                }
            }
            result = services.joined(separator: ", ")
        } else {
            result = "None"
        }

        return result
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

    static func anyManufacturerDataToHexString(_ data: Any) -> String {
        let stringInputValue = data as? String ?? ""
        let startIndex = stringInputValue.firstIndex(of: "x")
        let endIndex = stringInputValue.lastIndex(of: "}")

        let inputStringHex = String(stringInputValue[(startIndex!)..<endIndex!])
        var cleanInput = inputStringHex.replacingOccurrences(of: " ", with: "")
        cleanInput = cleanInput.replacingOccurrences(of: "x", with: "")
        cleanInput = cleanInput.replacingOccurrences(of: ".", with: "")
        let output = cleanInput.replacingOccurrences(of: "}", with: "")

        print(output)
        return output
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
