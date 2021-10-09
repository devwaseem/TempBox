//
//  AttachmentsView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 05/10/21.
//

import Foundation
import SwiftUI
import MailTMSwift

struct AttachmentsView: View {
    
    @ObservedObject var controller: AttachmentsViewController
    
    var title: String {
        let pluralizedWord = controller.attachments.count == 1 ? "Attachment" : "Attachments"
        return "\(controller.attachments.count) \(pluralizedWord)"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .frame(height: 1)
                .opacity(0.2)
            HStack {
                Image(systemName: "paperclip")
                Text(title)
                    .opacity(0.7)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(controller.attachments, id: \.id) { attachment in
                        if let downloadTask = controller.attachmentDownloadTasks[attachment.id] {
                            AttachmentCell(attachment: attachment, downloadTask: downloadTask, controller: controller)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
}

fileprivate struct AttachmentCell: View {
    
    @State var downloadPercentage: Double = 0
    @ObservedObject var downloadTask: FileDownloadTask
    @ObservedObject var controller: AttachmentsViewController
    
    var attachment: MTAttachment
    
    init(attachment: MTAttachment, downloadTask: FileDownloadTask, controller: AttachmentsViewController) {
        self.attachment = attachment
        self.downloadTask = downloadTask
        self.controller = controller
    }

    var isDownloading: Bool {
        downloadTask.state == .downloading
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(attachment.filename)
                    .truncationMode(.middle)
                    .frame(maxWidth: 150, alignment: .leading)
                Text(humanReadableFileSize)
                    .opacity(0.6)
                    .font(.caption)
            }
            .frame(height: 30)
            .padding(.leading, 4)
            
            controlView
                .padding(.leading)
            
        }
        .padding()
        .frame(minWidth: 140, alignment: .leading)
        .background(Color.primary.opacity(0.2))
        .background(
            Color.accentColor.opacity(0.1)
                .animation(.easeOut)
                .scaleEffect(x: downloadPercentage, y: 1, anchor: .leading)
                .opacity(isDownloading ? 1 : 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            controller.onAttachmentTap(attachment: attachment)
        }
        .onReceive(downloadTask.progress
                    .publisher(for: \.fractionCompleted)
                    .receive(on: DispatchQueue.main)
        ) { value in
            downloadPercentage = value
        }
    }
    
    @ViewBuilder
    var controlView: some View {
        switch downloadTask.state {
            case .idle:
                Image(systemName: "icloud.and.arrow.down")
                    .padding(.leading)
            case .downloading:
                ProgressView()
                    .controlSize(.small)
            default:
                EmptyView()
        }
    }
    
    var humanReadableFileSize: String {
        ByteCountFormatter.string(from:
                                        .init(value: Double(attachment.size),
                                              unit: .kilobytes),
                                  countStyle: .file)
    }
    
}
