//
//  AccountInfoViewController.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 03/10/21.
//

import Foundation
import AppKit

class AccountInfoViewController: ObservableObject {
    
    let pasteboard: NSPasteboard
    
    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }
    
    func copyStringToPasteboard(value: String) {
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(value, forType: .string)
    }
}
