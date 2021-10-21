//
//  MessageDownloadManager.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 09/10/21.
//

import Foundation
import Resolver
import MailTMSwift
import OSLog

class MessageDownloadManager {
    static let logger = Logger(subsystem: Logger.subsystem, category: String(describing: MessageDownloadManager.self))
    private var messageDownloadTasks: [Message.ID: FileDownloadTask] = [:]
    
    private let fileDownloadManager: FileDownloadManager
    
    private let decoder = JSONDecoder()
    
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
        let task = fileDownloadManager.schedule(with: request, fileName: fileName, saveLocation: saveLocation,
                                                beforeSave: extractSource(location:), afterDownload: afterDownload)
        messageDownloadTasks[message.id] = task
        task.download()
        return task
    }
    
    func extractSource(location: URL) -> URL? {
        guard FileManager.default.fileExists(atPath: location.path) else {
            return nil
        }
        
        do {
            guard let data = try String(contentsOf: location).data(using: .utf8) else {
                return nil
            }
            let sourceObj = try decoder.decode(MTMessageSource.self, from: data)
            
            let temporaryDirectoryURL =
            try FileManager.default.url(for: .itemReplacementDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: location,
                                            create: true)

            let temporaryFilename = UUID().uuidString

            let temporaryFileURL =
                temporaryDirectoryURL.appendingPathComponent(temporaryFilename)

            try sourceObj.data.write(to: temporaryFileURL, atomically: true, encoding: .utf8)
            return temporaryFileURL
        } catch {
            Self.logger.error("\(#function) \(#line) \(error.localizedDescription)")
        }
        return nil
    }
}
