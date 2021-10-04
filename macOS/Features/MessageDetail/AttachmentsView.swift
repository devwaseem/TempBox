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
    
    var attachments: [MTAttachment]
    
    var title: String {
        let pluralizedWord = attachments.count == 1 ? "Attachment" : "Attachments"
        return "\(attachments.count) \(pluralizedWord)"
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
                    ForEach(attachments, id: \.id) { attachment in
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "photo")
                            VStack(alignment: .leading, spacing: 4) {
                                Text(attachment.filename)
                                Text(humanReadableFileSize(sizeInBytes: attachment.size))
                                    .opacity(0.6)
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .frame(minWidth: 140, alignment: .leading)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }
    
    func humanReadableFileSize(sizeInBytes: Int) -> String {
        ByteCountFormatter.string(from: Measurement<UnitInformationStorage>(value: Double(sizeInBytes), unit: .bytes),
                                  countStyle: .file)
    }
    
}

struct AttachmentsView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentsView(attachments: [MTAttachment(id: "1",
                                            filename: "Mermaid.png",
                                            contentType: "",
                                            disposition: "",
                                            transferEncoding: "",
                                            related: false,
                                            size: 100,
                                            downloadURL: ""),
                                      MTAttachment(id: "2",
                                            filename: "Dog.png",
                                            contentType: "",
                                            disposition: "",
                                            transferEncoding: "",
                                            related: false,
                                            size: 640000,
                                            downloadURL: ""),
                                        MTAttachment(id: "3",
                                              filename: "Cat.png",
                                              contentType: "",
                                              disposition: "",
                                              transferEncoding: "",
                                              related: false,
                                              size: 12400000,
                                              downloadURL: "")
                                     ])
            .padding()
            .previewLayout(.fixed(width: 500, height: 500))
    }
}
