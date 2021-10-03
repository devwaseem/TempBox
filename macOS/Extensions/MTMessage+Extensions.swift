//
//  MTMessage+Extensions.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 02/10/21.
//

import Foundation
import MailTMSwift

extension MTMessage {
    
    var textExcerpt: String {
        let maxCharCount = 600
        if let intro = intro {
            return intro
        }
        guard let text = text else {
            return ""
        }
        let start = text.startIndex
        let end = text.index(start, offsetBy: min(text.count, maxCharCount))
        return String(text[start..<end])
    }
    
}
