//
//  Logger.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 26/09/21.
//

import Foundation
import OSLog

extension Logger {
    static var subsystem = Bundle.main.bundleIdentifier!

    static let notifications = Logger(subsystem: subsystem, category: "Notifications")
    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    static let fileDownloadManager = Logger(subsystem: subsystem, category: String(describing: FileDownloadManager.self))
        
    enum Services {
        static let accountService = Logger(subsystem: subsystem, category: String(describing: AccountService.self))
    }
    
    enum Repositories {
        static let account = Logger(subsystem: subsystem, category: String(describing: AccountRepository.self))
    }
    
}
