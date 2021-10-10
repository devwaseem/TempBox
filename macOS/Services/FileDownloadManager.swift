//
//  FileDownloader.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 06/10/21.
//

import Foundation
import Combine
import AppKit

class FileDownloadTask: ObservableObject {
    
    enum State {
        case idle
        case downloading
        case saved
        case error
    }
    
    var id: Int {
        task.taskIdentifier
    }
    
    let task: URLSessionDownloadTask
    let savedFileLocation: URL
    let fileName: String
    var error: Error?
    var beforeSave: ((URL) -> URL?)?
    var afterDownload: ((FileDownloadTask) -> Void)?
    
    @Published var state: State = .idle
    
    var progress: Progress {
        task.progress
    }
    
    init (task: URLSessionDownloadTask, fileName: String, savedFileLocation: URL,
          beforeSave: ((URL) -> URL?)? = nil, afterDownload: ((FileDownloadTask) -> Void)? = nil) {
        self.task = task
        self.savedFileLocation = savedFileLocation
        self.fileName = fileName
        self.error = nil
        self.beforeSave = beforeSave
        self.afterDownload = afterDownload
    }
    
    func download() {
        guard state != .downloading else {
            return
        }
        state = .downloading
        task.resume()
    }
    
}

final class FileDownloadManager: NSObject {
        
    var tasks: [Int: FileDownloadTask] = [:]
        
    lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }()
    
    private static var downloadDirectoryURL: URL {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    }
  
    func schedule(with request: URLRequest, fileName: String, saveLocation: URL? = nil,
                  beforeSave: ((URL) -> URL?)? = nil, afterDownload: ((FileDownloadTask) -> Void)? = nil) -> FileDownloadTask {
        let downloadTask = session.downloadTask(with: request)
        let fileURL: URL
        if let saveLocation = saveLocation {
            fileURL = saveLocation
        } else {
            fileURL = Self.downloadDirectoryURL.appendingPathComponent(fileName)
        }
        let fileDownloadTask = FileDownloadTask(task: downloadTask,
                                                fileName: fileName,
                                                savedFileLocation: fileURL,
                                                beforeSave: beforeSave,
                                                afterDownload: afterDownload)
        tasks[fileDownloadTask.id] = fileDownloadTask
        return fileDownloadTask
    }
    
}

extension FileDownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let task = tasks[downloadTask.taskIdentifier] else {
            return
        }
        
        let sourceFile = task.beforeSave?(location) ?? location
        
        let savingLocation = task.savedFileLocation
        
        do {
            let isFileExists = FileManager.default.fileExists(atPath: savingLocation.path)
            if isFileExists {
                _ = try FileManager.default.replaceItemAt(savingLocation, withItemAt: sourceFile)
            } else {
                try FileManager.default.moveItem(at: sourceFile, to: savingLocation)
            }
            task.state = .saved
            task.afterDownload?(task)
        } catch {
            print(error)
            task.state = .error
            task.error = error
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error, let file = tasks[task.taskIdentifier] else {
            return
        }
        
        file.state = .error
        file.error = error
        
    }
    
}
