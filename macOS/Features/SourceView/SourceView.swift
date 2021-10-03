//
//  SourceView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 03/10/21.
//

import SwiftUI

struct SourceView: View {
    
    @EnvironmentObject var windowManager: SourceWindowManager
    
    var source: String {
        windowManager.currentSourceString
    }
        
    var body: some View {
        TextEditor(text: .constant(source))
            .padding()
        .navigationTitle("Source")
        .toolbar {
            
            ToolbarItem(placement: .automatic) {
                Button {
                    windowManager.downloadSourceFile()
                } label: {
                    Label("Download", systemImage: "icloud.and.arrow.down")
                }
                .help("Download source")
            }
            
            ToolbarItem(placement: .automatic) {
                Button {
                    windowManager.copySourceToPasteboard()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .help("Copy source")
            }
            
        }
    }
    
    func copySourceToPasteboard() {
        
    }
}

struct SourceView_Previews: PreviewProvider {
    
    static let windowManger: SourceWindowManager = {
        let window = SourceWindowManager()
        window.openWindow(with: Array(repeating: "-", count: 10000).joined(separator: ""))
        return window
    }()
    
    static var previews: some View {
        SourceView()
            .environmentObject(windowManger)
        
    }
}
