//
//  ModelContainerManager.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import Foundation
import SwiftData

/** Initializes the Context to use SwiftData.

 */
struct ModelContainerContext {
    //MARK: - PROPERTIES
    static let shared : ModelContainerContext = .init()

    //MARK: - INITIALIZER
    private init() {}

    //MARK: - FUNCTIONS
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Device.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
