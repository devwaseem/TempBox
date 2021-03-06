//
//  MessageDetailViewController.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 09/10/21.
//

import Foundation
import Resolver
import MailTMSwift
import AppKit
import Combine
import OSLog
import UserNotifications

class MessageDetailViewController: ObservableObject {
    static let logger = Logger(subsystem: Logger.subsystem, category: String(describing: MessageDetailViewController.self))
    @Published var showError = false
    @Published var errorMessage = ""
        
    private var mtMessageService: MTMessageService
    var downloadManager: MessageDownloadManager
    private(set) var message: Message
    private(set) var account: Account
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var currentDownloadingFileState = FileDownloadTask.State.idle
    
    @Published var currentDownloadingFile: FileDownloadTask? {
        didSet {
            if let currentDownloadingFile = currentDownloadingFile {
                currentDownloadingFile.$state
                    .sink(receiveValue: { [weak self] state in
                        guard let self = self else { return }
                        self.currentDownloadingFileState = state
                    })
                    .store(in: &subscriptions)
            } else {
                self.currentDownloadingFileState = .idle
            }
        }
    }
    
    var isDownloading: Bool {
        return currentDownloadingFileState == .downloading
    }
    
    var downloadProgress: Progress? {
        return currentDownloadingFile?.progress
    }
        
    init(
        mtMessageService: MTMessageService = Resolver.resolve(),
        downloadManager: MessageDownloadManager = Resolver.resolve(),
        message: Message,
        account: Account) {
            self.mtMessageService = mtMessageService
            self.downloadManager = downloadManager
            self.message = message
            self.account = account
            restoreDownloadIfAny()
        }
    
    func restoreDownloadIfAny() {
        currentDownloadingFile = downloadManager.file(for: self.message)
    }
    
    func downloadMessage(message: Message, for account: Account) {
        guard let request = mtMessageService.getSourceRequest(id: message.id, token: account.token) else {
            errorMessage = "Something went wrong, Please try again later"
            showError = true
            return
        }
        
        let downloadDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let panel = NSSavePanel()
        panel.directoryURL = downloadDirectory
        panel.nameFieldLabel = "Save file as:"
        panel.nameFieldStringValue = message.data.subject + ".eml"
        panel.canCreateDirectories = true
        panel.showsTagField = false
        panel.begin { [weak self] response in
            guard let self = self else { return }
            if response == NSApplication.ModalResponse.OK, let desiredUrl = panel.url {
                self.currentDownloadingFile = self.downloadManager.download(message: message,
                                                                            request: request,
                                                                            saveLocation: desiredUrl, afterDownload: { _ in
                    self.triggerNotificationForDownloadedMessage(fileName: panel.nameFieldStringValue, savedLocation: desiredUrl)
                })
            }
        }
    }
    
    private func saveSource(fileName: String, source: MTMessageSource) {
        
        let panel = NSSavePanel()
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        panel.nameFieldLabel = "Save file as:"
        panel.nameFieldStringValue = fileName
        panel.canCreateDirectories = true
        panel.showsTagField = false
        
        panel.begin { response in
            if response == NSApplication.ModalResponse.OK, let fileUrl = panel.url {
                do {
                    try source.data.write(to: fileUrl, atomically: true, encoding: .utf8)
                } catch {
                    Self.logger.error("\(#function) \(#line): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func triggerNotificationForDownloadedMessage(fileName: String, savedLocation: URL) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Message downloaded"
        content.subtitle = fileName
        content.sound = nil
        content.categoryIdentifier = LocalNotificationKeys.Category.openFileFromLocation
        content.userInfo = ["location": savedLocation.absoluteString]
        
        let openAction = UNNotificationAction(identifier: "Open", title: "Open", options: .foreground)
        let category = UNNotificationCategory(identifier: LocalNotificationKeys.Identifiers.message,
                                              actions: [openAction],
                                              intentIdentifiers: [])
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.setNotificationCategories([category])
        center.add(request) { error in
            if let error = error {
                Self.logger.error("\(#function) \(#line): Message Notification: \(error.localizedDescription)")
            }
        }
    }
    
}
