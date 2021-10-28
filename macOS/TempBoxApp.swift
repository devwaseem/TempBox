//
//  TempBoxApp.swift
//  Shared
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI
import Combine
import Resolver
import Sparkle

@main
struct TempBoxApp: App {

    // swiftlint:disable weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // swiftlint:enable weak_delegate
    
    @StateObject var appController = AppController()
    @StateObject var updaterViewController = UpdaterViewController()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appController)
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .help) {
                Button("Github") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/devwaseem/TempBox")!)
                }
                Button("Website") {
                    NSWorkspace.shared.open(URL(string: "https://tempbox.waseem.works")!)
                }
                Button("Developer") {
                    NSWorkspace.shared.open(URL(string: "https://waseem.works")!)
                }
                Divider()
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
            
            CommandGroup(replacing: .newItem) {
                Button("New Address") {
                    NotificationCenter.default.post(name: .newAddress, object: nil)
                }
                .keyboardShortcut("n")
                
            }
            
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updaterViewController: updaterViewController)
            }
        }
        
    }
}
