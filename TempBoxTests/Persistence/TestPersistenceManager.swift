//
//  TestPersistence.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import CoreData
@testable import TempBox

class TestPersistenceManager: PersistenceManager {
    override init() {
        super.init()
        let container = NSPersistentContainer(name: Self.modelName, managedObjectModel: Self.model)
        // Prevent saving it to the file store, In effect, we can work with objects in memory
        container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        self.storeContainer = container
    }
}
