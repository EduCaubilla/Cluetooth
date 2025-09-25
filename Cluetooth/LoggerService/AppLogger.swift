//
//  AppLogger.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 22/9/25.
//

import Foundation
import os.log

struct AppLogger {
    //MARK: - PROPERTIES
    private static let bundleId: String = "com.educaubilla.Cluetooth"

    private static let appPrefix: String = "CLTH "
    private static var currentTime: String {
        return dateFormatter.string(from: Date.now)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy_HH:mm:ss"
        return formatter
    }()

    //MARK: - FUNCTIONS
    /// Log info messages
    static func info(_ message: String, category: String = "bluetooth", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        Logger(subsystem: bundleId, category: category).info("\(appPrefix)\(currentTime) - INFO: \(fileName)/\(function):\(line) - \(message)")
    }

    /// Log debug messages (only in debug builds)
    static func debug(_ message: String, category: String = "bluetooth", file: String = #file, function: String = #function, line: Int = #line) {
#if DEBUG
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        Logger(subsystem: bundleId, category: category).debug("\(appPrefix)\(currentTime) - DEBUG: \(fileName)/\(function):\(line) - \(message)")
#endif
    }

    /// Log warning messages
    static func warning(_ message: String, category: String = "bluetooth", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        Logger(subsystem: bundleId, category: category).warning("\(appPrefix)\(currentTime) - WARNING: \(fileName)/\(function):\(line) - \(message)")
    }

    /// Log error messages
    static func error(_ message: String, error: Error? = nil, category: String = "bluetooth", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let errorDescription = error?.localizedDescription ?? ""
        let fullMessage = errorDescription.isEmpty ? message : "\(message) - Error: \(errorDescription)"
        Logger(subsystem: bundleId, category: category).error("\(appPrefix)\(currentTime) - ERROR: \(fileName)/\(function):\(line) - \(fullMessage)")
    }

    /// Log critical/fault messages
    static func critical(_ message: String, error: Error? = nil, category: String = "bluetooth", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let errorDescription = error?.localizedDescription ?? ""
        let fullMessage = errorDescription.isEmpty ? message : "\(message) - Error: \(errorDescription)"
        Logger(subsystem: bundleId, category: category).critical("\(appPrefix)\(currentTime) - CRITICAL: \(fileName)/\(function):\(line) - \(fullMessage)")
    }
}
