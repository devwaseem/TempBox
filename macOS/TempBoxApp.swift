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
    
    @StateObject var appController = AppController()
    @StateObject var sourceViewController = SourceWindowManager()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appController)
                .environmentObject(sourceViewController)
        }
        .handlesExternalEvents(matching: [WindowManager.mainView.rawValue])
        
        WindowGroup {
            SourceView()
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 800, maxHeight: .infinity)
                .environmentObject(sourceViewController)
        }
        .handlesExternalEvents(matching: [WindowManager.sourceView.rawValue])
        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: true))
    }
}

enum WindowManager: String, CaseIterable {
    case sourceView = "com-tempbox-source-window"
    case mainView = "com-tempbox-main-window"
    
    func open() {
        if let url = URL(string: "tempbox://\(self.rawValue)") {
            print("opening \(self.rawValue)")
            NSWorkspace.shared.open(url)
        }
    }
}
