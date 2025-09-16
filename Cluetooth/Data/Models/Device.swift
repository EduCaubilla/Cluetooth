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
    @Transient var connected: Bool = false
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
    var servicesData : [DMService] { services.map { DMService(service: $0) }
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
    }
}

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
            let key = BluetoothUUIDMapper.getCharacteristicDescription(for: characteristic.uuid)

            var value : String = ""

            if let data = characteristic.value, !data.isEmpty {
                if key == "Battery Level" {
                    value = "\(String(data[0], radix: 10))%"
                } else if key == "Current Time" {
                    value = utils.parseCurrentTimeCharacteristic(data: data) ?? ""
                } else if key == "Local Time" {
                    value = utils.parseLocalTimeInformationCharacteristic(data: data) ?? ""
                } else {
                    if let string = String(data: data, encoding: .utf8), !string.isEmpty {
                        value = string
                    } else {
                        // Show hex representation if not valid UTF-8
                        value = data.map { String(format: "%02X", $0) }.joined(separator: " ")
                    }
                }

                convertedCharacteristics[key] = value
                print("==========")
                print("Characteristic ----> \(key): \(value)")
                dump(data)
                print("")
            }
        }

        return convertedCharacteristics
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
                print("Data Timestamp ----> \(inputValue)")
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

    static func parseCurrentTimeCharacteristic(data: Data) -> String? {
        guard data.count >= 7 else { return nil }

        // Extract year (little-endian)
        let year = Int(data[0]) | (Int(data[1]) << 8)
        let month = Int(data[2])
        let day = Int(data[3])
        let hours = Int(data[4])
        let minutes = Int(data[5])
        let seconds = Int(data[6])

        // Validate the values
        guard year > 0 && month >= 1 && month <= 12 && day >= 1 && day <= 31 &&
                hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59 &&
                seconds >= 0 && seconds <= 59 else {
            return nil
        }

        // Create DateComponents
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hours
        components.minute = minutes
        components.second = seconds

        // Create Date
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return nil }

        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss | dd MMM yyyy"

        return dateFormatter.string(from: date)
    }

    static func parseLocalTimeInformationCharacteristic(data: Data) -> String? {
        guard data.count >= 2 else { return nil }

        // Extract timezone offset (signed 8-bit integer)
        let timeZoneQuarters = Int8(bitPattern: data[0])
        let dstQuarters = Int(data[1])

        // Convert to seconds (each unit = 15 minutes = 900 seconds)
        let timeZoneOffsetSeconds = Int(timeZoneQuarters) * 15 * 60
        let dstOffsetSeconds = TimeInterval(dstQuarters * 15 * 60)

        // Create TimeZone
        let timeZone = TimeZone(secondsFromGMT: timeZoneOffsetSeconds)

        var resultString = ""
        resultString += "TimeZone: \(timeZone?.identifier ?? "")"
        resultString += "\nDST: \(dstOffsetSeconds / 3600) hours"

        return resultString
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

struct DMService {
    let uid: String = UUID().uuidString
    let name: String
    let characteristics: [String : String]

    init(name: String, characteristics: [String : String]) {
        self.name = name
        self.characteristics = characteristics
    }

    init(service: CBService) {
        self.name = BluetoothUUIDMapper.getServiceDescription(for: service.uuid.uuidString)
        self.characteristics = Device.characteristicConverter(for: service.characteristics ?? [])
    }
}
