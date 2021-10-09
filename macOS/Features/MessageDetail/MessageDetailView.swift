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
    @ObservedObject var controller: MessageDetailViewController
    
    var isLoading: Bool {
        !selectedMessage.isComplete
    }
    
    var html: String {
        selectedMessageData.html?.joined(separator: "") ?? ""
    }
    
    var selectedMessageData: MTMessage {
        selectedMessage.data
    }
    
    var selectedMessage: Message {
        controller.message
    }
            
    var selectedAccount: Account {
        controller.account
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                MessageDetailHeader(viewModel: .init(from: selectedMessageData.from,
                                                     cc: selectedMessageData.cc,
                                                     bcc: selectedMessageData.bcc,
                                                     subject: selectedMessageData.subject,
                                                     date: selectedMessageData.createdAt
                                                    ))
                Spacer()
            }
            .padding([.top, .horizontal])
            if isLoading {
                loadingView
            } else {
                VStack {
                    WebView(html: html)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(12)
                        .padding(24)
                    if let account = selectedAccount, let attachments = selectedMessage.data.attachments, !attachments.isEmpty {
                        AttachmentsView(controller: AttachmentsViewController(account: account, attachments: attachments))
                            .padding(.horizontal)
                    }
                }
            }
        }
        .alert(isPresented: $controller.showError, content: {
            Alert(title: Text(controller.errorMessage), message: nil, dismissButton: .default(Text("OK"), action: {
                controller.errorMessage = ""
            }))
        })
        .toolbar { toolbar }
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
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Spacer()
        }

        ToolbarItem(placement: .automatic) {
            if let progress = controller.downloadProgress, controller.isDownloading {
                MessageDetailDownloadView(progress: progress)
            } else {
                Button {
                    controller.downloadMessage(message: selectedMessage, for: selectedAccount)
                } label: {
                    Label("Download", systemImage: "icloud.and.arrow.down")
                }
                .help("Download message")
            }
        }
        
        ToolbarDivider()
        
        ToolbarItem(placement: .destructiveAction) {
            Button {
                appController.deleteMessage(message: selectedMessage, for: selectedAccount)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .help("Delete selected message")
        }
    }
}

fileprivate struct MessageDetailDownloadView: View {
    
    @State var fractionComplete: Double = 0
    
    var progress: Progress
    
    var body: some View {
        ProgressView(value: fractionComplete, total: 100) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "icloud.and.arrow.down")
                Text("\(Int(fractionComplete))% completed")
            }
        }
        .controlSize(.small)
        .onReceive(progress
                    .publisher(for: \.fractionCompleted)
                    .receive(on: DispatchQueue.main),
                   perform: { value in
            self.fractionComplete = value * 100
        })
        .progressViewStyle(LinearProgressViewStyle())
    }
}
