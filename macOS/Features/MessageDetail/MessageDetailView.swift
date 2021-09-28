//
//  MessageDetailView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

struct MessageDetailView: View {
    var body: some View {
//        Text("No Message Selected")
//            .font(.largeTitle)
//            .opacity(0.4)
        VStack(alignment: .leading) {
            HStack {
                MessageDetailHeader()
                Spacer()
            }
            .padding()
            WebView(html: "<p>Soon there will be content here</p>")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .toolbar(content: {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {}, label: {
                    Label("Delete", systemImage: "trash")
                })
            }
        })
    }
}

private struct MessageDetailHeader: View {

    var body: some View {
        HStack {
            Color.blue
                .clipShape(Circle())
                .frame(width: 40, height: 40)
                .overlay(
                    Text("W")
                        .font(.title2)
                        .fontWeight(.bold)
                )
                .padding()
            VStack(alignment: .leading, spacing: 6.0) {
                Text("Swiggy (noreply@swiggy.in)")
                    .font(.system(size: 16))
                Text("Your Swiggy order was delivered superfast!")
                    .font(.system(size: 12))
                HStack(spacing: 2.0) {
                    Text("To:")
                    Text("Waseem Akram")
                        .opacity(0.8)
                }
                .font(.system(size: 12))
            }
        }
    }

}

struct MessageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetailView()
            .previewLayout(.fixed(width: 600, height: 800))
    }
}
