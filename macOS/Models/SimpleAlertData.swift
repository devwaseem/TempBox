//
//  SimpleAlertData.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 21/10/21.
//

import Foundation

struct SimpleAlertData: Identifiable {
    var id: String {
        title
    }
    let title: String
    let message: String?
}

extension SimpleAlertData: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.title = value
        self.message = nil
    }
}
