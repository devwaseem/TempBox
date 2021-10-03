//
//  QuotaView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 17/09/21.
//

import SwiftUI

struct QuotaView: View {
    
    @State var isHintShowing = false

    var value: Int32
    var total: Int32
    
    var isQuotaAlmostComplete: Bool {
        (Float(value) / Float(total)) > 0.85
    }
    
    var valueInMb: String {
        ByteCountFormatter.string(from: Measurement<UnitInformationStorage>(value: Double(value), unit: .bytes),
                                  countStyle: .file)
    }
    
    var totalInMb: String {
        ByteCountFormatter.string(from: Measurement<UnitInformationStorage>(value: Double(total), unit: .bytes),
                                  countStyle: .file)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Quota left")
                    .font(.headline)
                Spacer()
                Button {
                    isHintShowing = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(isHintShowing ? Color.accentColor : Color.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $isHintShowing) {
                    Text("Once you reach your Quota limit, you cannot receive any more messages. " +
                         "Deleting your previous messages will free up your used Quota.")
                        .frame(width: 400)
                        .padding()
                }
            }
            
            ProgressView(value: Float(value), total: Float(total)) {
                HStack(alignment: .center) {
                    Text("\(valueInMb) / \(totalInMb)")
                    if isQuotaAlmostComplete {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                }
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
        QuotaView(value: 1_000_000, total: 100_000_000)
        QuotaView(value: 90_000_000, total: 100_000_000)
            .previewDisplayName("Quota almost complete")
    }
}
