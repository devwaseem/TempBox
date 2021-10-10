//
//  TempBoxApp.swift
//  Shared
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI
import Combine
import Resolver
import Defaults
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
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
        registerNotifications()
        
    }
    
    func registerNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { accepted, error in
            if let error = error {
                print(error)
                return
            }
            Defaults[.isNotificationsEnabled] = accepted
            if !accepted {
                print("Notification access denied.")
            }
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        persistenceManager.saveMainContext()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        if categoryIdentifier == "openFileFromLocation" {
            let userInfo = response.notification.request.content.userInfo
            
            if let fileLocation = userInfo["location"] as? String, let fileUrl = URL(string: fileLocation) {
                if response.actionIdentifier == "Open" {
                    NSWorkspace.shared.open(fileUrl)
                }
            }
        }
        completionHandler()
    }
    
}

@main
struct TempBoxApp: App {

    // swiftlint:disable weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // swiftlint:enable weak_delegate
    
    @StateObject var appController = AppController()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appController)
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .help) {
                Button("API") {
                    NSWorkspace.shared.open(URL(string: "https://docs.mail.tm")!)
                }
                Button("FAQ") {
                    NSWorkspace.shared.open(URL(string: "https://mail.tm/en/faq/")!)
                }
                Button("Privacy policy") {
                    NSWorkspace.shared.open(URL(string: "https://mail.tm/en/privacy/")!)
                }
                Button("Contact Mail.tm") {
                    NSWorkspace.shared.open(URL(string: "https://mail.tm/en/contact/")!)
                }
            }
        }
        
    }
}
