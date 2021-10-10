//
//  MessageDownloadManager.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 09/10/21.
//

import Foundation
import Resolver
import MailTMSwift

class MessageDownloadManager {
                
    private var messageDownloadTasks: [Message.ID: FileDownloadTask] = [:]
    
    private let fileDownloadManager: FileDownloadManager
    
    init(fileDownloadManger: FileDownloadManager = Resolver.resolve()) {
        self.fileDownloadManager = fileDownloadManger
    }
    
    func file(for message: Message) -> FileDownloadTask? {
        guard let fileTask = messageDownloadTasks[message.id] else {
            return nil
        }
        return fileDownloadManager.tasks[fileTask.id]
    }
    
    func download(message: Message, request: URLRequest, saveLocation: URL, afterDownload: ((FileDownloadTask) -> Void)? = nil) -> FileDownloadTask {
        let fileName: String
        if message.data.subject.isEmpty {
            fileName = "message.eml"
        } else {
            fileName = "\(message.data.subject).eml"
        }
        let task = fileDownloadManager.schedule(with: request, fileName: fileName, saveLocation: saveLocation, afterDownload: afterDownload)
        messageDownloadTasks[message.id] = task
        task.download()
        return task
    }
}
