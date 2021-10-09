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
    
    @Published var state: State = .idle
    
    var progress: Progress {
        task.progress
    }

    var progressSubscription: AnyCancellable?
    
    init (task: URLSessionDownloadTask, fileName: String, savedFileLocation: URL) {
        self.task = task
        self.savedFileLocation = savedFileLocation
        self.fileName = fileName
        self.error = nil
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
  
    func schedule(with request: URLRequest, fileName: String, saveLocation: URL? = nil) -> FileDownloadTask {
        let downloadTask = session.downloadTask(with: request)
        let fileURL: URL
        if let saveLocation = saveLocation {
            fileURL = saveLocation
        } else {
            fileURL = Self.downloadDirectoryURL.appendingPathComponent(fileName)
        }
        let fileDownloadTask = FileDownloadTask(task: downloadTask, fileName: fileName, savedFileLocation: fileURL)
        tasks[fileDownloadTask.id] = fileDownloadTask
        return fileDownloadTask
    }
    
}

extension FileDownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let task = tasks[downloadTask.taskIdentifier] else {
            return
        }
        
        let desiredUrl = task.savedFileLocation
        do {
            let isFileExists = FileManager.default.fileExists(atPath: desiredUrl.path)
            if isFileExists {
                _ = try FileManager.default.replaceItemAt(desiredUrl, withItemAt: location)
            } else {
                try FileManager.default.moveItem(at: location, to: desiredUrl)
            }
            task.state = .saved
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
