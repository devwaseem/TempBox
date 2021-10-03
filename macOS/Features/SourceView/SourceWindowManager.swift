//
//  SourceViewController.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 03/10/21.
//

import Foundation
import MailTMSwift
import AppKit

class SourceWindowManager: ObservableObject {
    
    private(set) var currentSourceString: String = ""
            
    func openWindow(with source: String) {
        self.currentSourceString = source
        WindowManager.sourceView.open()
    }
    
    func copySourceToPasteboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(currentSourceString, forType: .string)
    }
    
    func downloadSourceFile() {
        let panel = NSSavePanel()
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldLabel = "Save source file as:"
        panel.canCreateDirectories = true
        panel.showsTagField = false
        
        panel.begin { [weak self] response in
            guard let self = self else { return }
            if response == NSApplication.ModalResponse.OK, let fileUrl = panel.url {
                do {
                    try self.currentSourceString.write(to: fileUrl, atomically: true, encoding: .utf8)
                } catch {
                    print(error)
                }
            }
        }
    }
}
