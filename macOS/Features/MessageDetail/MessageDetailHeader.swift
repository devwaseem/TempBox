//
//  MessageDetailHeader.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 02/10/21.
//

import Foundation
import SwiftUI
import MailTMSwift

struct MessageDetailHeader: View {
    
    let viewModel: MessageDetailHeaderViewModel
    
    var body: some View {
        HStack {
            Color.accentColor
                .clipShape(Circle())
                .frame(width: 40, height: 40)
                .overlay(
                    Text(viewModel.imageCharacter)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .padding()
            
            VStack(alignment: .leading, spacing: 6.0) {
                HStack {
                    Text("\(viewModel.fromName) (\(viewModel.fromAddress))")
                        .font(.system(size: 16))
                        .lineLimit(1)
                    Spacer()
                    Text(viewModel.createdAtDate)
                        .layoutPriority(1)
                        .font(.caption)
                }
                Text(viewModel.subject)
                    .font(.system(size: 12))
                CCView(viewModel: viewModel)
                BCCView(viewModel: viewModel)
            }
        }
    }
    
}

// swiftlint:disable private_over_fileprivate
fileprivate struct CCView: View {
    
    let viewModel: MessageDetailHeaderViewModel
    
    @State var showCCList = false
    
    var body: some View {
        if viewModel.ccList.isEmpty {
           EmptyView()
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 2.0) {
                Text("CC: ")
                HStack {
                    ForEach(viewModel.viewableCCList, id: \.self) { cc in
                        Text("\(cc),")
                            .opacity(0.8)
                    }
                }
                if viewModel.isCCListBig {
                    Button {
                        showCCList = true
                    } label: {
                        Text("Show All")
                            .foregroundColor(.accentColor)
                            .font(.caption2)
                            .padding(.leading, 2)
                    }
                    .popover(isPresented: $showCCList) {
                        Text(viewModel.ccList.joined(separator: "\n"))
                            .fixedSize()
                            .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
            }
            .font(.system(size: 12))
        }
    }
    
}

fileprivate struct BCCView: View {
    
    let viewModel: MessageDetailHeaderViewModel
    
    @State var showBCCList = false
    
    var body: some View {
        if viewModel.bccList.isEmpty {
           EmptyView()
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 2.0) {
                Text("CC: ")
                HStack {
                    ForEach(viewModel.viewableBCCList, id: \.self) { bcc in
                        Text("\(bcc),")
                            .opacity(0.8)
                    }
                }
                if viewModel.isCCListBig {
                    Button {
                        showBCCList = true
                    } label: {
                        Text("Show All")
                            .foregroundColor(.accentColor)
                            .font(.caption2)
                            .padding(.leading, 2)
                    }
                    .popover(isPresented: $showBCCList) {
                        Text(viewModel.bccList.joined(separator: "\n"))
                            .fixedSize()
                            .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
            }
            .font(.system(size: 12))
        }
    }
    
}
// swiftlint:enable private_over_fileprivate

struct MessageDetailHeaderViewModel {
    let maxAccountListCount = 2
    
    var from: MTMessageUser?
    var cc: [MTMessageUser]?
    var bcc: [MTMessageUser]?
    var subject: String
    var date: Date
    
    var fromName: String {
        from?.name ?? "---"
    }
    
    var fromAddress: String {
        from?.address ?? "---"
    }
    
    var ccList: [String] {
        cc?.map(\.address) ?? []
    }
    
    var bccList: [String] {
        bcc?.map(\.address) ?? []
    }
    
    var isCCListBig: Bool {
        ccList.count > maxAccountListCount
    }
    
    var isBCCListBig: Bool {
        bccList.count > maxAccountListCount
    }
    
    var viewableCCList: [String] {
        return Array(ccList[..<min(ccList.count, maxAccountListCount)])
    }
    
    var viewableBCCList: [String] {
        return Array(bccList[..<min(bccList.count, maxAccountListCount)])
    }
    
    var imageCharacter: String {
        (fromName.first ?? "*").uppercased()
    }
    
    var createdAtDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy 'at' hh:mm a"
        return dateFormatter.string(from: date)
    }
}

struct MessageDetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetailHeader(viewModel: .init(from: .init(address: "from@example.com", name: "Waseem Akram"),
                                             cc: [
                                                 .init(address: "CC1@example.com", name: "CC1"),
                                                 .init(address: "CC2@example.com", name: "CC2")
                                             ],
                                             bcc: [
                                                 .init(address: "CC1@example.com", name: "CC1"),
                                                 .init(address: "CC2@example.com", name: "CC2")
                                             ],
                                             subject: "This is a Subject",
                                             date: Date()
                                            ))
            .previewLayout(.fixed(width: 500, height: 800))
    }
}
