//
//  ToolbarDivider.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 03/10/21.
//

import SwiftUI

struct ToolbarDivider: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            Rectangle()
                .frame(width: 1, height: 18)
                .opacity(0.1)
        }
    }
}
