//
//  AttachmentsViewController.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 07/10/21.
//

import Foundation
import Combine
import Resolver
import MailTMSwift
import AppKit
import UserNotifications

final class AttachmentsViewController: ObservableObject {
    
    var account: Account
    @Published var attachments: [MTAttachment]
    @Published var attachmentDownloadTasks: [MTAttachment: FileDownloadTask] = [:]
    
    private var downloadManager: AttachmentDownloadManager = Resolver.resolve()
    
    var subscriptions: Set<AnyCancellable> = []
    
    init(account: Account, attachments: [MTAttachment]) {
        self.account = account
        self.attachments = attachments
        registerAttachments()
        restoreDownloadTasks()
    }
    
    func restoreDownloadTasks() {
        attachmentDownloadTasks = attachments.reduce(into: [MTAttachment: FileDownloadTask]()) { dict, attachment in
            if let file = downloadManager.file(for: attachment) {
                dict[attachment] = file
            }
        }

        attachmentDownloadTasks.values.forEach { file in
            file.$state.sink { [weak self] _ in
                guard let self = self else { return }
                self.objectWillChange.send()
            }
            .store(in: &subscriptions)
        }
    }
    
    func registerAttachments() {
        for attachment in attachments {
            try? downloadManager.add(attachment: attachment, for: account, afterDownload: { [weak self] task in
                guard let self = self else { return }
                self.triggerNotificationForDownloadedAttachment(fileName: task.fileName, savedLocation: task.savedFileLocation)
            })
        }
    }
    
    func onAttachmentTap(attachment: MTAttachment) {
        guard let task = attachmentDownloadTasks[attachment], task.state != .downloading else {
            return
        }
        
        if task.state == .saved {
            openAttachment(attachment: attachment)
        } else {
            download(attachment: attachment)
        }
    }
    
    func openAttachment(attachment: MTAttachment) {
        guard let task = attachmentDownloadTasks[attachment], task.state == .saved else {
            return
        }
        NSWorkspace.shared.open(task.savedFileLocation)
    }
    
    func download(attachment: MTAttachment) {
        downloadManager.download(attachment: attachment, onRenew: { [weak self] newFileTask in
            guard let self = self else { return }
            self.attachmentDownloadTasks[attachment] = newFileTask
            self.objectWillChange.send()
        })
    }
    
    func triggerNotificationForDownloadedAttachment(fileName: String, savedLocation: URL) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Attachment downloaded."
        content.subtitle = fileName
        content.sound = .default
        content.userInfo = ["location": savedLocation.absoluteString]
        
        let openAction = UNNotificationAction(identifier: "Open", title: "Open", options: [.foreground, .authenticationRequired])
        let category = UNNotificationCategory(identifier: "Attachment",
                                              actions: [openAction],
                                              intentIdentifiers: [],
                                              options: [.hiddenPreviewsShowSubtitle])
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.setNotificationCategories([category])
        center.add(request) { error in
            if let error = error {
                print("Attachment Notification:", error)
            }
        }
    }
    
}
