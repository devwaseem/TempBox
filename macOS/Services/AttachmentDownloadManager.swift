//
//  AttachmentDownloadManager.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 06/10/21.
//

import Foundation
import MailTMSwift

class AttachmentDownloadManager {
    
    enum Error: Swift.Error {
        case alreadyScheduled
        case notScheduled
    }
        
    private var attachmentTasks: [MTAttachment.ID: FileDownloadTask] = [:]
    
    let fileDownloadManager: FileDownloadManager
    
    init(fileDownloadManger: FileDownloadManager) {
        self.fileDownloadManager = fileDownloadManger
    }
    
    func file(for attachment: MTAttachment) -> FileDownloadTask? {
        guard let fileTask = attachmentTasks[attachment.id] else {
            return nil
        }
        return fileDownloadManager.tasks[fileTask.id]
    }
    
    func add(attachment: MTAttachment, for account: Account, afterDownload: ((FileDownloadTask) -> Void)? = nil) throws {
        guard attachmentTasks[attachment.id] == nil else {
            throw Error.alreadyScheduled
        }
        
        guard !attachment.downloadURL.isEmpty else {
            return
        }
        
        let downloadUrl = "https://api.mail.tm" + attachment.downloadURL
        
        guard let url = URL(string: downloadUrl) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(account.token)"]
        request.httpMethod = "GET"
        let task = fileDownloadManager.schedule(with: request, fileName: attachment.filename, afterDownload: afterDownload)
        attachmentTasks[attachment.id] = task
    }
        
    func download(attachment: MTAttachment, onRenew: ((FileDownloadTask) -> Void)?) {
        guard let task = attachmentTasks[attachment.id] else {
            return
        }
        if task.state == .idle {
            task.download()
        } else {
            if let task = renewTask(attachment: attachment, oldTask: task) {
                onRenew?(task)
                task.download()
            }
        }
    }

    private func renewTask(attachment: MTAttachment, oldTask task: FileDownloadTask) -> FileDownloadTask? {
        guard let request = task.task.originalRequest else {
            return nil
        }
        
        let afterDownload = task.afterDownload
        let task = fileDownloadManager.schedule(with: request, fileName: attachment.filename, afterDownload: afterDownload)
        attachmentTasks[attachment.id] = task
        return task
    }
}
