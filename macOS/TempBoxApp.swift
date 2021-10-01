//
//  TempBoxApp.swift
//  Shared
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI
import Combine
import Resolver

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    @Injected var persistenceManager: PersistenceManager

    var popover = NSPopover.init()
    var statusBar: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
//        popover.contentSize = NSSize(width: 360, height: 360)
//        popover.contentViewController = NSHostingController(rootView:
//                                                                VStack{
//                                                                    List {
//                                                                        Text("1")
//                                                                        Text("2")
//                                                                    }
//                                                                    .listStyle(SidebarListStyle())
//                                                                })
//        statusBar = StatusBarController(popover)
        print(persistenceManager.mainContext)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        persistenceManager.saveMainContext()
    }

}

@main
struct TempBoxApp: App {

    // swiftlint:disable weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // swiftlint:enable weak_delegate

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .presentedWindowStyle(HiddenTitleBarWindowStyle())
        }
    }
}
