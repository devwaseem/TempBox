//
//  CheckForUpdatesView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 28/10/21.
//

import SwiftUI

struct CheckForUpdatesView: View {
    @ObservedObject var updaterViewController: UpdaterViewController
    
    var body: some View {
        Button("Check For Updates…", action: updaterViewController.checkForUpdates)
            .disabled(!updaterViewController.canCheckForUpdates)
    }
}
