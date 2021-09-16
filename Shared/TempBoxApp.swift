//
//  TempBoxApp.swift
//  Shared
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

@main
struct TempBoxApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
