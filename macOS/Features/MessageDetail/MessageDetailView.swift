//
//  MessageDetailView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI
import MailTMSwift

struct MessageDetailView: View {
    
    @EnvironmentObject var appController: AppController
    @EnvironmentObject var sourceViewWindowManger: SourceWindowManager
        
    var isLoading: Bool {
        !(selectedMessage?.isComplete ?? false)
    }
    
    var html: String {
        selectedMessageData?.html?.joined(separator: "") ?? ""
    }
    
    var selectedMessageData: MTMessage? {
        appController.selectedMessage?.data
    }
    
    var selectedMessage: Message? {
        appController.selectedMessage
    }
        
    var attachments: [MTAttachment] {
        selectedMessage?.data.attachments ?? []
    }
    
    var body: some View {
        if let selectedMessage = selectedMessageData {
            VStack(alignment: .leading) {
                HStack {
                    MessageDetailHeader(viewModel: .init(from: selectedMessage.from,
                                                         cc: selectedMessage.cc,
                                                         bcc: selectedMessage.bcc,
                                                         subject: selectedMessage.subject,
                                                         date: selectedMessage.createdAt
                                                        ))
                    Spacer()
                }
                .padding()
                if isLoading {
                    loadingView
                } else {
                    VStack {
                        WebView(html: html)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(12)
                            .padding(24)
                            .padding(.top, -24)
                        if !attachments.isEmpty {
                            AttachmentsView(attachments: attachments)
                                .padding(.horizontal)
                        }
                    }
                }
                
            }
            .toolbar(content: {
                
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        if let selectedMessage = self.selectedMessage, let selectedAccount = appController.selectedAccount {
                            appController.deleteMessage(message: selectedMessage, for: selectedAccount)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .help("Delete selected message")
                }
                
                ToolbarDivider()
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        if let selectedMessage = self.selectedMessage, let selectedAccount = appController.selectedAccount {
                            appController.downloadMessage(message: selectedMessage, for: selectedAccount)
                        }
                    } label: {
                        Label("Download", systemImage: "icloud.and.arrow.down")
                    }
                    .help("Download message")
                    .disabled(!(self.selectedMessage?.isSourceDownloaded ?? true))
                }
                
                ToolbarDivider()
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        if let selectedMessage = self.selectedMessage,
                           selectedMessage.isSourceDownloaded,
                           let source = selectedMessage.source {
                            sourceViewWindowManger.openWindow(with: source)
                        }
                    } label: {
                        Label("Source", systemImage: "chevron.left.slash.chevron.right")
                    }
                    .help("View Source")
                    .disabled(!(self.selectedMessage?.isSourceDownloaded ?? true))
                }
                
            })
        } else {
            notSelectedView
        }
    }
    
    var notSelectedView: some View {
        Text("No Message Selected")
            .font(.largeTitle)
            .opacity(0.4)
    }
    
    var loadingView: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Spacer()
                ProgressView()
                    .controlSize(.regular)
                Spacer()
            }
            Spacer()
        }
    }
}

struct MessageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetailView()
            .previewLayout(.fixed(width: 600, height: 800))
    }
}
