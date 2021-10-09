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

final class AttachmentsViewController: ObservableObject {
    
    var account: Account
    @Published var attachments: [MTAttachment]
    @Published var attachmentDownloadTasks: [MTAttachment.ID: FileDownloadTask] = [:]
    
    private var downloadManager: AttachmentDownloadManager = Resolver.resolve()
    
    var subscriptions: Set<AnyCancellable> = []
    
    init(account: Account, attachments: [MTAttachment]) {
        self.account = account
        self.attachments = attachments
        registerAttachments()
        restoreDownloadTasks()
    }
    
    func restoreDownloadTasks() {
        attachmentDownloadTasks = attachments.reduce(into: [MTAttachment.ID: FileDownloadTask]()) { dict, attachment in
            let id = attachment.id
            if let file = downloadManager.file(for: attachment) {
                dict[id] = file
            }
        }
        
        attachmentDownloadTasks.values.forEach { file in
            file.$state.sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &subscriptions)
        }
    }
    
    func registerAttachments() {
        for attachment in attachments {
            try? downloadManager.add(attachment: attachment, for: account)
        }
    }
    
    func onAttachmentTap(attachment: MTAttachment) {
        guard let task = attachmentDownloadTasks[attachment.id], task.state != .downloading else {
            return
        }
        
        if task.state == .saved {
            openAttachment(attachment: attachment)
        } else {
            download(attachment: attachment)
        }
    }
    
    func openAttachment(attachment: MTAttachment) {
        guard let task = attachmentDownloadTasks[attachment.id], task.state == .saved else {
            return
        }
        NSWorkspace.shared.open(task.savedFileLocation)
    }
    
    func download(attachment: MTAttachment) {
        downloadManager.download(attachment: attachment, onRenew: { [weak self] newFileTask in
            guard let self = self else { return }
            self.attachmentDownloadTasks[attachment.id] = newFileTask
            self.objectWillChange.send()
        })
    }
    
}
