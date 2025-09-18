//
//  Utils.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 18/9/25.
//

import Foundation

struct Utils {
    static func boolToDescription(_ value: Bool) -> String {
        return value ? "Yes" : "No"
    }

    static func mapToBool(_ value: String) -> Bool {
        return value == "1"
    }

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
        let dstOffsetHours = Int(TimeInterval(dstQuarters * 15 * 60)/3600)

        // Create TimeZone
        let timeZone = TimeZone(secondsFromGMT: timeZoneOffsetSeconds)

        var resultString = ""
        resultString += "\(timeZone?.identifier ?? "")"

        if dstOffsetHours > 0 {
            resultString += "\nDST: +\(dstOffsetHours) hour"
        }

        return resultString
    }
}
