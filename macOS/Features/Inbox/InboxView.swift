//
//  InboxView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

struct InboxView: View {

    @EnvironmentObject
    var appController: AppController

    var body: some View {
//        Text("No Messages")
//            .opacity(0.6)
        VStack {
            List(selection: .constant(0)) {
                ForEach(appController.selectedAccountMessages, id: \.id) { message in
                    InboxCell(username: "Swiggy",
                              subject: "Your Swiggy order was delivered superfast!",
                              content: "Your order was delivered within 43 minutes."
                              + "Rate this lightning fast delivery and add a tip for your delivery partner here"
                    )
                        .tag(message)
                }
            }
            .listStyle(InsetListStyle())
        }
        .navigationTitle("Inbox")
        .navigationSubtitle("0 Messages")
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {}, label: {
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                        .help("Filter by Unreads")
                })
            }
        })
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
