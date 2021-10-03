//
//  InboxView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

struct InboxView: View {
    
    @EnvironmentObject var appController: AppController
    
    var isFilterBySeenEnabled: Bool {
        appController.filterNotSeen
    }
    
    var messagesCount: String {
        let count = appController.selectedAccountMessages.count
        let unreadCount = appController.selectedAccountMessages.filter { !$0.data.seen }.count
        if appController.filterNotSeen {
            return "\(count) Unread"
        }
        if unreadCount == 0 {
            return "\(count) Messages"
        } else {
            return "\(count) Messages, \(unreadCount) unread"
        }
        
    }
    
    var body: some View {
        VStack {
            if appController.selectedAccount == nil {
                noAccountSelectedView
            } else if appController.selectedAccountMessages.isEmpty {
                noMessagesView
            } else {
                List(selection: $appController.selectedMessage) {
                    ForEach(appController.selectedAccountMessages, id: \.id) { message in
                        InboxCell(username: message.data.from.address,
                                  subject: message.data.subject,
                                  excerpt: message.data.textExcerpt,
                                  isSeen: message.data.seen,
                                  date: message.data.createdAt)
                            .tag(message)
                    }
                }
                .listStyle(InsetListStyle())
            }
        }
        .navigationTitle("Inbox")
        .navigationSubtitle(messagesCount)
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    appController.filterNotSeen.toggle()
                }, label: {
                    Label("Filter",
                          systemImage: "line.horizontal.3.decrease.circle\(isFilterBySeenEnabled ? ".fill" : "")")
                        .help("Filter by Unreads")
                            .foregroundColor(isFilterBySeenEnabled ? Color.accentColor : Color.primary)
                })
            }
        })
        
    }
    
    var noAccountSelectedView: some View {
        Text("No Account Selected")
            .opacity(0.6)
    }
    
    var noMessagesView: some View {
        Text("No Messages")
            .opacity(0.6)
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
