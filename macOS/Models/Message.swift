//
//  Message.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 02/10/21.
//

import Foundation
import MailTMSwift

struct Message: Hashable, Identifiable {
    
    var isComplete: Bool = false
    var data: MTMessage
    var source: String?
    var isSourceDownloaded: Bool
        
    var id: String {
        data.id
    }
    
    init(isComplete: Bool = false, data: MTMessage, isSourceDownloaded: Bool = false, source: String? = nil) {
        self.isComplete = isComplete
        self.data = data
        self.isSourceDownloaded = isSourceDownloaded
        self.source = source
    }
    
}

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.data.id == rhs.data.id
    }
}
