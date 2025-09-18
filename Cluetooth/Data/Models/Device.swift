//
//  Item.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import SwiftUI
import SwiftData
import CoreBluetooth

//MARK: - MODEL
final class Device: Identifiable, ObservableObject {
    var uid: UUID
    var peripheral: CBPeripheral? = nil
    var name: String
    var advertisementData : [String: String]
    var services : [CBService] = []
    var characteristics : [CBCharacteristic] = []
    var rssi: Int
    var connected: Bool = false
    var connecting: Bool = false
    var timestamp: String?
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

    var servicesData : [Service] { services.map { Service(service: $0) }
}

    //MARK: - INITIALIZER
    init(peripheral: CBPeripheral,
         name: String,
         advertisementData: [String: String],
         services: [CBService],
         rssi: Int,
         timestamp: String?) {
        self.uid = peripheral.identifier.uuidString.isEmpty ? UUID() : UUID(uuidString: peripheral.identifier.uuidString)!
        self.peripheral = peripheral
        self.name = name
        self.advertisementData = advertisementData
        self.services = services
        self.rssi = rssi
        self.timestamp = timestamp ?? Utils.timeStampToDate(Date.now.timeIntervalSince1970)
    }

    init(peripheral: CBPeripheral,
         advertisementData: [String: Any],
         services: [CBService],
         connected: Bool = false) {
        self.uid = peripheral.identifier.uuidString.isEmpty ? UUID() : UUID(uuidString: peripheral.identifier.uuidString)!
        self.peripheral = peripheral
        self.name = peripheral.name ?? "Unknown"
        self.advertisementData = Device.advDataConverter(advertisementData)
        self.services = services
        self.rssi = 0
        self.connected = connected

        if advertisementData["kCBAdvDataTimestamp"] != nil {
            self.timestamp = Utils.timeStampToDate(advertisementData["kCBAdvDataTimestamp"] as! TimeInterval)
        } else {
            self.timestamp = timestamp ?? Utils.timeStampToDate(Date.now.timeIntervalSince1970)
        }
    }
}

//MARK: - EXT - Equatable
extension Device : Equatable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.uid == rhs.uid &&
        lhs.peripheral === rhs.peripheral &&
        lhs.name == rhs.name &&
        lhs.advertisementData == rhs.advertisementData &&
        lhs.services == rhs.services &&
        lhs.characteristics == rhs.characteristics &&
        lhs.rssi == rhs.rssi &&
        lhs.connected == rhs.connected &&
        lhs.connecting == rhs.connecting &&
        lhs.timestamp == rhs.timestamp &&
        lhs.expanded == rhs.expanded &&
        lhs.signalStrengthColor == rhs.signalStrengthColor &&
        lhs.id == rhs.id &&
        lhs.servicesData == rhs.servicesData
    }
}

//MARK: - EXT - Converters
extension Device {
    static func advDataConverter(_ advData: [String : Any]) -> [String: String] {
        var convertedAdvs : [String: String] = [:]

        advData.forEach{ key, value in
            let responseKey = ServiceAdvertisementDataKey.getDescription(for: key)
            let enumKeyValue = ServiceAdvertisementDataKey.setCase(for: key)
            let responseValue = getAdvertisementValueMapped(for: enumKeyValue ?? nil, with: "\(value)")
            convertedAdvs[responseKey ?? ""] = responseValue
        }

        return convertedAdvs
    }

    static func serviceConverter(for data: [CBService]) -> [String: String] {
        var convertedServices: [String: String] = [:]

        for service in data {
            let key = service.uuid.uuidString
            let value = BluetoothUUIDMapper.getServiceDescription(for: service.uuid)
            convertedServices[key] = value
        }
        return convertedServices
    }

    static func characteristicConverter(for data: [CBCharacteristic]) -> [String: String] {
        var convertedCharacteristics: [String: String] = [:]

        for characteristic in data {
            var key = BluetoothUUIDMapper.getCharacteristicDescription(for: characteristic.uuid)

            var value : String = ""

            if let data = characteristic.value, !data.isEmpty {
                if key == "Battery Level" {
                    value = "\(String(data[0], radix: 10))%"
                } else if key == "Current Time" {
                    value = Utils.parseCurrentTimeCharacteristic(data: data) ?? ""
                } else if key == "Local Time Information" {
                    key = "Local Time"
                    value = Utils.parseLocalTimeInformationCharacteristic(data: data) ?? ""
                } else {
                    if let string = String(data: data, encoding: .utf8), !string.isEmpty {
                        value = string
                    } else {
                        // Show hex representation if not valid UTF-8
                        value = data.map { String(format: "%02X", $0) }.joined(separator: " ")
                    }
                }

                convertedCharacteristics[key] = value
            }
        }

        return convertedCharacteristics
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
}

//MARK: - EXT - Adv Mapper
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
                return Utils.boolToDescription(Utils.mapToBool(inputValue as? String ?? "0")) // Bool

            case .CBAdvertisementDataManufacturerData:
                var response = "No data"
                let stringHex =  Utils.anyManufacturerDataToHexString(inputValue as? String ?? "")

                if let dataFromHex = Data(hexString: stringHex) {
                    response = BluetoothManufacturerMapper().parseManufacturerData(dataFromHex)!
                }

                return response

            case .CBAdvertisementDataTimestamp:
                let timestamp: Double = NSString(string:"\(inputValue)").doubleValue
                return Utils.timeStampToDate(timestamp) // Double

            default :
                return inputValue as? String ?? ""
        }
    }
}
