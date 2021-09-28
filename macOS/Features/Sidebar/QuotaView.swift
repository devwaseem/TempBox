//
//  QuotaView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 17/09/21.
//

import SwiftUI

struct QuotaView: View {

    var value: Int32
    var total: Int32

    var body: some View {
        VStack(alignment: .leading) {
            Text("Quota left")
                .font(.headline)
            ProgressView(value: Float(value), total: Float(total)) {
                Text("10 MB / 100 MB")
            }
            .padding(.top, 8)

        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(6)
    }
}

struct QuotaView_Previews: PreviewProvider {
    static var previews: some View {
        QuotaView(value: 10, total: 100)
    }
}
