//
//  AppDelegate.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 10/10/21.
//

import Foundation
import SwiftUI
import Resolver
import Defaults
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    @Injected var persistenceManager: PersistenceManager
        
    func applicationDidFinishLaunching(_ notification: Notification) {
        registerNotifications()
        NSWindow.allowsAutomaticWindowTabbing = false
        if let mainMenu = NSApp.mainMenu {
            DispatchQueue.main.async {
                if let edit = mainMenu.items.first(where: { $0.title == "Edit"}) {
                    mainMenu.removeItem(edit)
                }
            }
        }
        
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
        switch categoryIdentifier {
            case LocalNotificationKeys.Category.openFileFromLocation:
                let userInfo = response.notification.request.content.userInfo
                
                if let fileLocation = userInfo["location"] as? String, let fileUrl = URL(string: fileLocation) {
                    NSWorkspace.shared.open(fileUrl)
                }
            case LocalNotificationKeys.Category.activateMessage:
                let userInfo = response.notification.request.content.userInfo
                NotificationCenter.default.post(name: .activateAccountAndMessage, object: nil, userInfo: userInfo)
            default: break
        }
        completionHandler()
    }
    
}
