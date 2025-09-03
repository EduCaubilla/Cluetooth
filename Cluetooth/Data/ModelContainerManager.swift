//
//  ModelContainerManager.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import SwiftUI
import SwiftData
import CoreData

actor ModelContainerManager {
    //MARK: - PROPERTIES
    @Environment(\.modelContext) private var modelContext

    static var shared: ModelContainerManager = .init()

    //MARK: - INITIALIZER
    private init() {}

//MARK: - FUNCTIONS
    func insert<T: PersistentModel>(_ object: T) {
        modelContext.insert(object)
    }

    func delete<T: PersistentModel>(_ object: T) {
        modelContext.delete(object)
    }
}
