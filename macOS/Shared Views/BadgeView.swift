//
//  BadgeView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 17/09/21.
//

import SwiftUI

struct BadgeView: View {
    let model: BadgeViewModel

    let font = Font.system(size: 10, weight: .regular)
    let padding = EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)

    var body: some View {
        Text(model.title)
            .font(font)
            .foregroundColor(model.textColor)
            .padding(padding)
            .background(model.color)
            .cornerRadius(20)
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BadgeView(model: BadgeViewModel(title: "DEBUG", color: Color.red.opacity(0.3)))
        }
    }
}

struct BadgeViewModel {
    let title: String
    let color: Color
    var textColor: Color = .primary
}
