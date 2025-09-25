//
//  CluetoothApp.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import SwiftUI

@main
struct CluetoothApp: App {

    init() {
        AppLogger.info("App initialized", category: "app")
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    AppLogger.info("App became active", category: "app")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    AppLogger.info("App entered background", category: "app")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    AppLogger.info("App will terminate", category: "app")
                }
        }
    }
}
