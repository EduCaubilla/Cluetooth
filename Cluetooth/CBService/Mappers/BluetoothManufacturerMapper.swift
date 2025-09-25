//
//  BluetoothManufacturerMapper.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 10/9/25.
//

import Foundation

struct BluetoothManufacturerMapper {

    func mapCompanyIdToManufacturer(_ companyId: UInt16) -> String {
        switch companyId {
                // Major Tech Companies
            case 0x004C: return "Apple Inc."
            case 0x0006: return "Microsoft Corporation"
            case 0x00E0: return "Google"
            case 0x0075: return "Samsung Electronics Co. Ltd."
            case 0x000F: return "Broadcom Corporation"
            case 0x0001: return "Nokia Mobile Phones"
            case 0x000A: return "Qualcomm"
            case 0x000D: return "Texas Instruments Inc."
            case 0x003A: return "Panasonic"
            case 0x0008: return "Motorola"
            case 0x0002: return "Intel Corp."
            case 0x038F: return "Xiaomi Inc."
            case 0x0024: return "Alcatel"

                // Semiconductor Companies
            case 0x0059: return "Nordic Semiconductor ASA"
            case 0x0131: return "Cypress Semiconductor"
            case 0x0022: return "NEC Corporation"
            case 0x0013: return "Atmel Corporation"
            case 0x011B: return "Hewlett-Packard Company"
            case 0x02FF: return "Silicon Laboratories"
            case 0x0004: return "Toshiba Corp."
            case 0x0030: return "ST Microelectronics"

                // Fitness & Wearables
            case 0x0087: return "Garmin International, Inc."
            case 0x006B: return "Polar Electro Oy"
            case 0x009F: return "Suunto Oy"
            case 0x03FF: return "Withings"
//            case 0x0171: return "Amazfit (Zepp Health)" ??
            case 0x012D: return "Sony Corporation"

                // Audio Companies
            case 0x0055: return "Plantronics, Inc."
            case 0x009E: return "Bose Corporation"
            case 0x0494: return "Sennheiser"
//            case 0x0057: return "JBL - Harman" ?
            case 0x00CC: return "Beats Electronics"
            case 0x0007: return "Lucent"
            case 0x0103: return "Bang & Olufsen A/S"

                // Automotive
            case 0x0723: return "Ford Motor Company"
//            case 0x01F0: return "BMW Group" ?
            case 0x00B9: return "Johnson Controls, Inc."
            case 0x004b: return "Continental Automotive Systems"
            case 0x022B: return "Tesla Motors"
            case 0x010E: return "Audi AG"
            case 0x017C: return "Mercedes-Benz Group AG"
            case 0x0068: return "General Motors"
            case 0x011E: return "Skoda Auto"
            case 0x0A88: return "PSA Peugeot Citroen"
            case 0x0125: return "SEAT"
            case 0x011F: return "Volkwagen AG"

                // IoT & Smart Home
            case 0x01B5: return "Nest Labs Inc."
            case 0x01DD: return "Philips"
            case 0x0526: return "Honeywell International Inc."
            case 0x0171: return "Amazon.com Services, Inc."
            case 0x00C4: return "LG Electronics"
            case 0x0029: return "Hitachi, Ltd."

                // Gaming & Entertainment
            case 0x0553: return "Nintendo Co., Ltd."

                // Networking & Connectivity
            case 0x0026: return "C Technologies"
            case 0x022E: return "Siemens AG"
            case 0x0005: return "3Com Corporation"
            case 0x0031: return "Synopsys, Inc."
            case 0x0057: return "Harman International Industries, Inc."

                // Other
            case 0x5900: return "Fiido Electric Bikes"
            case 0x0078: return "Nike Inc"
            case 0x0062: return "Gibson Guitars"
            case 0x008C: return "Gimbal Inc."
            case 0x0B8A: return "Seiko"

                // Default case for unknown manufacturers
            default: return "Unknown Manufacturer (ID: 0x\(String(format: "%04X", companyId)))"
        }
    }

    func parseManufacturerData(_ data: Data) -> String? {
        guard data.count >= 2 else {
            AppLogger.debug("Error parsing data: Manufacturer data too short", category: "data")
            return nil
        }

        // Extract company ID (first 2 bytes, little-endian)
        let companyId = UInt16(data[0]) | (UInt16(data[1]) << 8)

        // Extract company-specific data (remaining bytes)
        let companyData = data.subdata(in: 2..<data.count)
        let companyName = mapCompanyIdToManufacturer(companyId)

        // Parse company-specific data
        let parsedData = parseCompanySpecificData(companyId: companyId, data: companyData)

        var manufacturerStringResponse: String = ""

        var i = 0
        parsedData.forEach { key, value in
            if let stringValue = value as? String {
                manufacturerStringResponse += "\(key): \(stringValue)"
                if (i > 0 && parsedData.count > 1) || i == parsedData.count - 1 {
                    manufacturerStringResponse += "\n"
                }
                i += 1
            }
        }

        return manufacturerStringResponse
    }

    func parseCompanySpecificData(companyId: UInt16, data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        switch companyId {
            case 0x004C:
                result = parseAppleData(data)
            case 0x0059:
                result = parseNordicData(data)
            case 0x02E5:
                result = parseFitbitData(data)
            case 0x00E0:
                result = parseGoogleData(data)
            case 0x0006:
                result = parseMicrosoftData(data)
            case 0x0075:
                result = parseSamsungData(data)
            case 0x0118:
                result = parseLGData(data)
            case 0x038F:
                result = parseXiaomiData(data)
            default:
                result = parseGenericData(data)
        }

        return result
    }

    // MARK: - Apple Data Parser
    func parseAppleData(_ data: Data) -> [String: String] {
        var result: [String: String] = ["company": "Apple"]
        guard data.count > 0 else { return result }

        let type = data[0]
        result["type"] = String(type)
        result["type_hex"] = String(format: "0x%02X", type)

        switch type {
            case 0x02: // iBeacon
                if let iBeacon = parseAppleIBeacon(data) {
                    result["beacon_type"] = "iBeacon"
                    result["uuid"] = iBeacon.uuid.uuidString
                    result["major"] = String(iBeacon.major)
                    result["minor"] = String(iBeacon.minor)
                    result["tx_power"] = String(iBeacon.txPower)
                    result["description"] = "iBeacon UUID: \(iBeacon.uuid.uuidString), Major: \(iBeacon.major), Minor: \(iBeacon.minor)"
                }
            case 0x05: // AirDrop
                result["service"] = "AirDrop"
                result["description"] = "AirDrop advertisement"
            case 0x07, 0x08, 0x09: // AirPods/Audio
                result["service"] = "AirPods/Audio"
                if data.count > 1 {
                    let resultData = parseAppleBatteryInfo(data.subdata(in: 1..<data.count))
                    let resultString = ""
                    result["battery_info"] = resultString.appending(resultData.values.joined(separator: ", "))
                }
            case 0x0A: // Hey Siri
                result["service"] = "Hey Siri"
                result["description"] = "Hey Siri availability"
            case 0x0C: // Handoff
                result["service"] = "Handoff"
                result["description"] = "Handoff/Continuity"
            case 0x10: // Nearby Action
                result["service"] = "Nearby Action"
                if data.count >= 3 {
                    result["action_type"] = String(data[1])
                    result["action_flags"] = String(data[2])
                }
            default:
                result["service"] = "Unknown Apple Service"
                result["description"] = "Unknown Apple data type: 0x\(String(format: "%02X", type))"
        }

        return result
    }

    func parseAppleIBeacon(_ data: Data) -> iBeaconData? {
        // iBeacon format: Type(1) + Length(1) + UUID(16) + Major(2) + Minor(2) + TxPower(1)
        guard data.count >= 23 else { return nil }

        let uuidData = data.subdata(in: 2..<18)
        let uuid = UUID(uuid: uuidData.withUnsafeBytes { $0.load(as: uuid_t.self) })

        let major = data.subdata(in: 18..<20).withUnsafeBytes {
            UInt16(bigEndian: $0.load(as: UInt16.self))
        }
        let minor = data.subdata(in: 20..<22).withUnsafeBytes {
            UInt16(bigEndian: $0.load(as: UInt16.self))
        }
        let txPower = Int8(bitPattern: data[22])

        return iBeaconData(uuid: uuid, major: major, minor: minor, txPower: txPower)
    }

    func parseAppleBatteryInfo(_ data: Data) -> [String: String] {
        var batteryInfo: [String: String] = [:]

        guard data.count >= 1 else { return batteryInfo }

        // This is simplified - Apple's battery format can be complex
        if data.count >= 2 {
            batteryInfo["left_battery"] = String(Int(data[0]))
            batteryInfo["right_battery"] = String(Int(data[1]))
        }
        if data.count >= 3 {
            batteryInfo["case_battery"] = String(Int(data[2]))
        }

        return batteryInfo
    }

    // MARK: - Other Company Parsers
    func parseGoogleData(_ data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        guard data.count > 0 else { return result }

        // Google Eddystone or other formats
        if data.count >= 2 {
            result["service_type"] = data[0]
            result["frame_type"] = data[1]

            if data[0] == 0xAA && data[1] == 0xFE { // Eddystone
                result["beacon_type"] = "Eddystone"
                if data.count > 2 {
                    switch data[2] {
                        case 0x00: result["eddystone_type"] = "UID"
                        case 0x10: result["eddystone_type"] = "URL"
                        case 0x20: result["eddystone_type"] = "TLM"
                        case 0x30: result["eddystone_type"] = "EID"
                        default: result["eddystone_type"] = "Unknown"
                    }
                }
            }
        }

        return result
    }

    func parseFitbitData(_ data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        if data.count >= 1 {
            result["device_type"] = data[0]
            // Fitbit often includes device model info
            if data.count >= 4 {
                result["device_id"] = data.subdata(in: 1..<4).hexString
            }
        }

        return result
    }

    func parseNordicData(_ data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        // Nordic devices often use standard formats or custom protocols
        if data.count >= 1 {
            result["protocol_version"] = data[0]
            if data.count > 1 {
                result["device_data"] = data.subdata(in: 1..<data.count).hexString
            }
        }

        return result
    }

    func parseMicrosoftData(_ data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        guard data.count >= 1 else { return result }

        // Microsoft Surface, Xbox, or other devices
        result["device_type"] = data[0]
        if data.count > 1 {
            // Check for specific Microsoft protocols
            if data[0] == 0x01 {
                result["service"] = "Surface/Windows Device"
            } else if data[0] == 0x02 {
                result["service"] = "Xbox Controller"
            }
        }

        return result
    }

    func parseSamsungData(_ data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        if data.count >= 2 {
            result["service_type"] = data[0]
            result["device_type"] = data[1]

            // Samsung SmartThings or Galaxy devices
            if data[0] == 0x42 {
                result["service"] = "SmartThings"
            } else if data[0] == 0x75 {
                result["service"] = "Galaxy Device"
            }
        }

        return result
    }

    func parseLGData(_ data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        guard data.count > 0 else { return result }

        if data.count >= 2 {
            result["service_type"] = data[0]
            result["frame_type"] = data[1]
        }

        return result
    }

    func parseXiaomiData(_ data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        if data.count >= 2 {
            result["service_type"] = data[0]
            result["frame_type"] = data[1]
        }

        return result
    }

    func parseGenericData(_ data: Data) -> [String: Any] {
        var result: [String: Any] = [:]

        result["length"] = data.count
        result["description"] = "Generic manufacturer data"

        // Try to identify common patterns
        if data.count >= 16 && data.count <= 25 {
            // Might be a beacon
            result["possible_type"] = "Beacon-like data"
        } else if data.count <= 4 {
            // Might be simple device identifier
            result["possible_type"] = "Device identifier"
        } else {
            result["possible_type"] = "Custom protocol"
        }

        return result
    }

}

// MARK: Models for conversion
struct AppleData {
    let type: UInt8
    let length: UInt8
    let payload: Data
    var description: String {
        switch type {
            case 0x02: return "iBeacon"
            case 0x05: return "AirDrop"
            case 0x07, 0x08, 0x09: return "AirPods/Proximity"
            case 0x0A: return "Hey Siri"
            case 0x0C: return "Handoff"
            case 0x10: return "Nearby Action"
            default: return "Unknown Apple Type"
        }
    }
}

struct iBeaconData {
    let uuid: UUID
    let major: UInt16
    let minor: UInt16
    let txPower: Int8
}

// MARK: - Utility Extensions
extension Data {
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined(separator: " ")
    }

    var hexStringCompact: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
