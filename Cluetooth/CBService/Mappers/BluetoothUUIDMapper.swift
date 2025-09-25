//
//  BluetoothUUIDMapper.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 9/9/25.
//

import Foundation
import CoreBluetooth

// MARK: - Bluetooth UUID Mapper
struct BluetoothUUIDMapper {

    // MARK: - Service Mappings
    private static let serviceDescriptions: [String: String] = [
        // Standard Services
        "1800": "Generic Access",
        "1801": "Generic Attribute",
        "1802": "Immediate Alert",
        "1803": "Link Loss",
        "1804": "Tx Power",
        "1805": "Current Time Service",
        "1806": "Reference Time Update Service",
        "1807": "Next DST Change Service",
        "1808": "Glucose",
        "1809": "Health Thermometer",
        "180A": "Device Information",
        "180D": "Heart Rate",
        "180E": "Phone Alert Status Service",
        "180F": "Battery Service",
        "1810": "Blood Pressure",
        "1811": "Alert Notification Service",
        "1812": "Human Interface Device",
        "1813": "Scan Parameters",
        "1814": "Running Speed and Cadence",
        "1815": "Automation IO",
        "1816": "Cycling Speed and Cadence",
        "1818": "Cycling Power",
        "1819": "Location and Navigation",
        "181A": "Environmental Sensing",
        "181B": "Body Composition",
        "181C": "User Data",
        "181D": "Weight Scale",
        "181E": "Bond Management Service",
        "181F": "Continuous Glucose Monitoring",
        "1820": "Internet Protocol Support Service",
        "1821": "Indoor Positioning",
        "1822": "Pulse Oximeter Service",
        "1823": "HTTP Proxy",
        "1824": "Transport Discovery",
        "1825": "Object Transfer Service",
        "1826": "Fitness Machine",
        "1827": "Mesh Provisioning Service",
        "1828": "Mesh Proxy Service",
        "1829": "Reconnection Configuration",
        "183A": "Insulin Delivery",
        "183B": "Binary Sensor",
        "183C": "Emergency Configuration",
        "183D": "Authorization Control",
        "183E": "Physical Activity Monitor",
        "183F": "Elapsed Time",
        "1840": "Generic Health Sensor",
        "1843": "Audio Input Control",
        "1844": "Volume Control",
        "1845": "Volume Offset Control",
        "1846": "Coordinated Set Identification Service",
        "1847": "Device Time",
        "1848": "Media Control Service",
        "1849": "Generic Media Control Service",
        "184A": "Constant Tone Extension",
        "184B": "Telephone Bearer Service",
        "184C": "Generic Telephone Bearer Service",
        "184D": "Microphone Control",
        "184E": "Audio Stream Control Service",
        "184F": "Broadcast Audio Scan Service",
        "1850": "Published Audio Capabilities Service",
        "1851": "Basic Audio Announcement Service",
        "1852": "Broadcast Audio Announcement Service",
        "1853": "Common Audio Service",
        "1854": "Hearing Access Service",
        "1855": "Telephony and Media Audio Service",
        "1856": "Public Broadcast Announcement Service",
        "1857": "Electronic Shelf Label",
        "1858": "Gaming Audio Service",

        // Custom/Proprietary Services (16-bit)
        "FE00": "Continuous Glucose Monitoring",
        "FE01": "Dexcom Service",
        "FE02": "Dexcom Service",
        "FE59": "Nordic Semiconductor Service",
        "FE5A": "Gimbal Service",
        "FE5B": "Gimbal Service",
        "FE5C": "Gimbal Service",
        "FE5D": "Gimbal Service",
        "FE5E": "Gimbal Service",
        "FE5F": "Gimbal Service",
        "FE84": "Huawei Service",
        "FE87": "Huawei Service",
        "FE8F": "Huawei Service",
        "FE95": "Google Service",
        "FE9F": "Google Service",
        "FEA0": "Google Service",
        "FEAA": "Google Service",
        "FEDC": "Tile Service",
        "FEDD": "Tile Service",
        "FEDE": "Tile Service",
        "FEDF": "Tile Service",
        "FEE0": "Xiaomi Service",
        "FEE1": "Xiaomi Service",
        "FEE7": "Xiaomi Service",
        "FEEA": "Xiaomi Service",
        "FEEB": "Xiaomi Service",
        "FEEC": "Xiaomi Service",
        "FEED": "Xiaomi Service",
        "FEEE": "Xiaomi Service",
        "FEEF": "Xiaomi Service",
        "FEF0": "Xiaomi Service",

        "FFE0": "Temperature Sensor",

        // 128-bit Custom Services (common ones)
        "6E400001-B5A3-F393-E0A9-E50E24DCCA9E": "Nordic UART Service",
        "4FAFC201-1FB5-459E-8FCC-C5C9C331914B": "ESP32 Custom Service",
        "7905F431-B5CE-4E99-A40F-4B1E122D00D0": "Apple Notification Center Service",
        "89D3502B-0F36-433A-8EF4-C502AD55F8DC": "Apple Media Service",
        "9FA480E0-4967-4542-9390-D343DC5D04AE": "Apple Media Remote Service",
        "6217FF4C-C8EC-B1FB-1380-3AD986708E2D": "Polar H7 Heart Rate",
        "0000FEE0-0000-1000-8000-00805F9B34FB": "Xiaomi Mi Band",
        "ADABFB00-6E7D-4601-BDA2-BFFAA68956BA": "Fitbit Service",
        "558DFA00-4FA8-4105-9F02-4EAA93E62980": "Thingy Configuration Service",
        "EF680100-9B35-4933-9B10-52FFA9740042": "Thingy Environment Service",
        "EF680200-9B35-4933-9B10-52FFA9740042": "Thingy User Interface Service",
        "EF680300-9B35-4933-9B10-52FFA9740042": "Thingy Motion Service",
        "EF680400-9B35-4933-9B10-52FFA9740042": "Thingy Sound Service",
        "EF680500-9B35-4933-9B10-52FFA9740042": "Thingy DFU Service"
    ]

    // MARK: - Characteristic Mappings
    private static let characteristicDescriptions: [String: String] = [
        // Generic Access
        "2A00": "Device Name",
        "2A01": "Appearance",
        "2A02": "Peripheral Privacy Flag",
        "2A03": "Reconnection Address",
        "2A04": "Peripheral Preferred Connection Parameters",
        "2A05": "Service Changed",

        // Device Information
        "2A23": "System ID",
        "2A24": "Model Number String",
        "2A25": "Serial Number String",
        "2A26": "Firmware Revision String",
        "2A27": "Hardware Revision String",
        "2A28": "Software Revision String",
        "2A29": "Manufacturer Name String",
        "2A2A": "IEEE 11073-20601 Regulatory Certification Data List",
        "2A50": "PnP ID",

        // Battery Service
        "2A19": "Battery Level",
        "2A1A": "Battery Power State",
        "2A1B": "Battery Level State",

        // Heart Rate
        "2A37": "Heart Rate Measurement",
        "2A38": "Body Sensor Location",
        "2A39": "Heart Rate Control Point",

        // Health Thermometer
        "2A1C": "Temperature Measurement",
        "2A1D": "Temperature Type",
        "2A1E": "Intermediate Temperature",
        "2A21": "Measurement Interval",

        // Blood Pressure
        "2A35": "Blood Pressure Measurement",
        "2A36": "Intermediate Cuff Pressure",
        "2A49": "Blood Pressure Feature",

        // Current Time
        "2A2B": "Current Time",
        "2A0F": "Local Time Information",
        "2A14": "Reference Time Information",
        "2A16": "Time Update Control Point",
        "2A17": "Time Update State",
        "2A11": "Time with DST",
        "2A12": "Time Zone",
        "2A13": "DST Offset",

        // Glucose
        "2A18": "Glucose Measurement",
        "2A34": "Glucose Measurement Context",
        "2A51": "Glucose Feature",
        "2A52": "Record Access Control Point",

        // Running Speed and Cadence
        "2A53": "RSC Measurement",
        "2A54": "RSC Feature",
        "2A55": "SC Control Point",

        // Cycling Speed and Cadence
        "2A5B": "CSC Measurement",
        "2A5C": "CSC Feature",
        "2A5D": "Sensor Location",

        // Cycling Power
        "2A63": "Cycling Power Measurement",
        "2A64": "Cycling Power Vector",
        "2A65": "Cycling Power Feature",
        "2A66": "Cycling Power Control Point",

        // Location and Navigation
        "2A67": "Location and Speed",
        "2A68": "Navigation",
        "2A69": "Position Quality",
        "2A6A": "LN Feature",
        "2A6B": "LN Control Point",

        // Environmental Sensing
        "2A6C": "Elevation",
        "2A6D": "Pressure",
        "2A6E": "Temperature",
        "2A6F": "Humidity",
        "2A70": "True Wind Speed",
        "2A71": "True Wind Direction",
        "2A72": "Apparent Wind Speed",
        "2A73": "Apparent Wind Direction",
        "2A74": "Gust Factor",
        "2A75": "Pollen Concentration",
        "2A76": "UV Index",
        "2A77": "Irradiance",
        "2A78": "Rainfall",
        "2A79": "Wind Chill",
        "2A7A": "Heat Index",
        "2A7B": "Dew Point",
        "2A7D": "Descriptor Value Changed",

        // Body Composition
        "2A9B": "Body Composition Feature",
        "2A9C": "Body Composition Measurement",

        // Weight Scale
        "2A9D": "Weight Scale Feature",
        "2A9E": "Weight Measurement",

        // User Data
        "2A8A": "First Name",
        "2A90": "Last Name",
        "2A87": "Email Address",
        "2A80": "Age",
        "2A85": "Date of Birth",
        "2A8C": "Gender",
        "2A8E": "Height",
        "2A98": "Weight",
        "2A96": "VO2 Max",
        "2A8F": "Hip Circumference",
        "2A97": "Waist Circumference",
        "2A7F": "Aerobic Heart Rate Lower Limit",
        "2A81": "Aerobic Heart Rate Upper Limit",
        "2A7E": "Aerobic Threshold",
        "2A83": "Anaerobic Heart Rate Lower Limit",
        "2A84": "Anaerobic Heart Rate Upper Limit",
        "2A82": "Anaerobic Threshold",
        "2A8D": "Heart Rate Max",
        "2A91": "Maximum Recommended Heart Rate",
        "2A86": "Date of Threshold Assessment",
        "2A92": "Resting Heart Rate",
        "2A93": "Sport Type for Aerobic and Anaerobic Thresholds",
        "2A94": "Three Zone Heart Rate Limits",
        "2A95": "Two Zone Heart Rate Limit",
        "2A99": "Database Change Increment",
        "2A9A": "User Index",
        "2A9F": "User Control Point",
        "2AA0": "Language",

        // Fitness Machine
        "2ACC": "Fitness Machine Feature",
        "2ACD": "Treadmill Data",
        "2ACE": "Cross Trainer Data",
        "2ACF": "Step Climber Data",
        "2AD0": "Stair Climber Data",
        "2AD1": "Rower Data",
        "2AD2": "Indoor Bike Data",
        "2AD3": "Training Status",
        "2AD4": "Supported Speed Range",
        "2AD5": "Supported Inclination Range",
        "2AD6": "Supported Resistance Level Range",
        "2AD7": "Supported Heart Rate Range",
        "2AD8": "Supported Power Range",
        "2AD9": "Fitness Machine Control Point",
        "2ADA": "Fitness Machine Status",

        // Audio
        "2B7D": "Volume State",
        "2B7E": "Volume Control Point",
        "2B7F": "Volume Flags",
        "2B80": "Volume Offset State",
        "2B81": "Audio Location",
        "2B82": "Volume Offset Control Point",
        "2B83": "Audio Output Description",
        "2B84": "Set Identity Resolving Key",
        "2B85": "Coordinated Set Size",
        "2B86": "Set Member Lock",
        "2B87": "Set Member Rank",
        "2B93": "Media Player Name",
        "2B94": "Media Player Icon Object ID",
        "2B95": "Media Player Icon URL",
        "2B96": "Track Changed",
        "2B97": "Track Title",
        "2B98": "Track Duration",
        "2B99": "Track Position",
        "2B9A": "Playback Speed",
        "2B9B": "Seeking Speed",
        "2B9C": "Current Track Segments Object ID",
        "2B9D": "Current Track Object ID",
        "2B9E": "Next Track Object ID",
        "2B9F": "Parent Group Object ID",
        "2BA0": "Current Group Object ID",
        "2BA1": "Playing Order",
        "2BA2": "Playing Orders Supported",
        "2BA3": "Media State",
        "2BA4": "Media Control Point",
        "2BA5": "Media Control Point Opcodes Supported",
        "2BA6": "Search Results Object ID",
        "2BA7": "Search Control Point",
        "2BA9": "Media Player Icon Object Type",
        "2BAA": "Track Segments Object Type",
        "2BAB": "Track Object Type",
        "2BAC": "Group Object Type",
        "2BAD": "Constant Tone Extension Enable",
        "2BAE": "Advertising Constant Tone Extension Minimum Length",
        "2BAF": "Advertising Constant Tone Extension Minimum Transmit Count",
        "2BB0": "Advertising Constant Tone Extension Transmit Duration",
        "2BB1": "Advertising Constant Tone Extension Interval",
        "2BB2": "Advertising Constant Tone Extension PHY",

        // Common 128-bit characteristics
        "6E400002-B5A3-F393-E0A9-E50E24DCCA9E": "Nordic UART RX",
        "6E400003-B5A3-F393-E0A9-E50E24DCCA9E": "Nordic UART TX",
        "BEB5483E-36E1-4688-B7F5-EA07361B26A8": "ESP32 Custom Characteristic"
    ]

    // MARK: - Public Methods

    /// Get service description from UUID
    static func getServiceDescription(for uuid: CBUUID) -> String {
        getServiceDescription(for: uuid.uuidString)
    }

    static func getServiceDescription(for uuidString: String) -> String {
        return serviceDescriptions[uuidString] ?? "Unknown Service\n(\(uuidString))"
    }

    /// Get characteristic description from UUID
    static func getCharacteristicDescription(for uuid: CBUUID) -> String {
        return getCharacteristicDescription(for: uuid.uuidString)
    }

    static func getCharacteristicDescription(for uuidString: String) -> String {
        return characteristicDescriptions[uuidString] ?? "Unknown Characteristic (\(uuidString))"
    }

    /// Get both service and characteristic info
    static func getServiceInfo(for uuid: CBUUID) -> (description: String, type: String) {
        let description = getServiceDescription(for: uuid)
        return (description, "Service")
    }

    static func getCharacteristicInfo(for uuid: CBUUID) -> (description: String, type: String) {
        let description = getCharacteristicDescription(for: uuid)
        return (description, "Characteristic")
    }

    /// Check if UUID is a standard Bluetooth SIG UUID
    static func isStandardUUID(_ uuid: CBUUID) -> Bool {
        let uuidString = uuid.uuidString.uppercased()

        // 16-bit UUIDs (4 characters) are standard
        if uuidString.count == 4 {
            return true
        }

        // 128-bit UUIDs ending with the Bluetooth base UUID are standard
        if uuidString.hasSuffix("-0000-1000-8000-00805F9B34FB") {
            return true
        }

        return false
    }

    /// Get category for a service UUID
    static func getServiceCategory(for uuid: CBUUID) -> String {
        let uuidString = normalizeUUID(uuid.uuidString)

        switch uuidString {
            case "1800", "1801":
                return "Core Services"
            case "180A", "180F":
                return "Device Information"
            case "180D", "1809", "1810", "1808", "1822", "181B", "181D":
                return "Health & Fitness"
            case "1816", "1818", "1814", "1826":
                return "Sports & Fitness"
            case "181A":
                return "Environmental"
            case "1812", "1802", "1803", "1804":
                return "Input/Output"
            case "1843", "1844", "1848", "184B":
                return "Audio & Media"
            case let uuid where uuid.hasPrefix("FE"):
                return "Proprietary"
            case let uuid where uuid.count > 4:
                return "Custom"
            default:
                return "Other"
        }
    }

    /// Get all services in a category
    static func getServicesInCategory(_ category: String) -> [(uuid: String, description: String)] {
        return serviceDescriptions.compactMap { key, value in
            if getServiceCategory(for: CBUUID(string: key)) == category {
                return (key, value)
            }
            return nil
        }.sorted { $0.uuid < $1.uuid }
    }

    /// Get all available categories
    static var allCategories: [String] {
        let categories = Set(serviceDescriptions.keys.map { getServiceCategory(for: CBUUID(string: $0)) })
        return Array(categories).sorted()
    }

    // MARK: - Private Methods

    /// Normalize UUID string for lookup
    private static func normalizeUUID(_ uuidString: String) -> String {
        let cleaned = uuidString.uppercased().replacingOccurrences(of: "-", with: "")

        // For 16-bit UUIDs, return just the 4 characters
        if cleaned.count >= 4 && cleaned.hasSuffix("00001000800000805F9B34FB") {
            return String(cleaned.prefix(4))
        }

        // For standard 128-bit UUIDs, extract the 16-bit part
        if cleaned.count == 32 && cleaned.hasSuffix("00001000800000805F9B34FB") {
            return String(cleaned.prefix(4))
        }

        // Return original with dashes for custom 128-bit UUIDs
        if cleaned.count == 32 {
            return "\(cleaned.prefix(8))-\(cleaned.dropFirst(8).prefix(4))-\(cleaned.dropFirst(12).prefix(4))-\(cleaned.dropFirst(16).prefix(4))-\(cleaned.suffix(12))"
        }

        return cleaned
    }
}
