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
        
    var id: String {
        data.id
    }
    
    internal init(isComplete: Bool = false, data: MTMessage) {
        self.isComplete = isComplete
        self.data = data
    }
    
}

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.data.id == rhs.data.id
    }
}
