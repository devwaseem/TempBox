//
//  Persistence.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 17/09/21.
//

import CoreData
import OSLog

open class PersistenceManager {
  public static let modelName = "TempBox"
  public static let model: NSManagedObjectModel = {
    // swiftlint:disable force_unwrapping
    let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
    // swiftlint:enable force_unwrapping
  }()

  public init() {
  }

  public lazy var mainContext: NSManagedObjectContext = {
    return self.storeContainer.viewContext
  }()

  public lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: Self.modelName, managedObjectModel: Self.model)
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unable to load persistent store")
      }
    }

    return container
  }()

  public func newDerivedContext() -> NSManagedObjectContext {
    let context = storeContainer.newBackgroundContext()
    return context
  }

  public func saveMainContext() {
    saveContext(mainContext)
  }

  public func saveContext(_ context: NSManagedObjectContext) {
    if context != mainContext {
      saveDerivedContext(context)
      return
    }

    context.perform {
      do {
        try context.save()
      } catch let error as NSError {
          Logger.persistence.error("Error while saving main context: \(error), \(error.userInfo)")
      }
    }
  }

  public func saveDerivedContext(_ context: NSManagedObjectContext) {
    context.perform {
      do {
        try context.save()
      } catch let error as NSError {
          Logger.persistence.error("Error while saving derived/child context: \(error), \(error.userInfo)")
      }

      self.saveContext(self.mainContext)
    }
  }
}
