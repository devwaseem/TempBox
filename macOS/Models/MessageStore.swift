//
//  MessageStore.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 02/10/21.
//

import Foundation
import MailTMSwift

struct MessageStore {
    var isFetching: Bool = false
    var error: MTError?
    var messages: [Message]
    
    var unreadMessagesCount: Int {
        return messages.filter { !$0.data.seen }.count
    }
}
