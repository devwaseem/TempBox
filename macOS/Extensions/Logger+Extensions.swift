//
//  Logger.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 26/09/21.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    
    enum Services {
        static let accountService = Logger(subsystem: subsystem, category: String(describing: AccountService.self))
    }
    
    enum Repositories {
        static let account = Logger(subsystem: subsystem, category: String(describing: AccountRepository.self))
    }
    
}
