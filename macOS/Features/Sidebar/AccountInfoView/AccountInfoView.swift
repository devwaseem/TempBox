//
//  AccountInfoView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 03/10/21.
//

import SwiftUI

struct AccountInfoView: View {
        
    var isActive: Bool
    var address: String
    var password: String
    var refresh: () -> Void
    
    @StateObject var controller = AccountInfoViewController()
    @State var isPasswordVisible = false
    @State var isHintShowing = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button {
                    isHintShowing = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(isHintShowing ? Color.accentColor : Color.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $isHintShowing) {
                    Text("If you wish to use this account on Web browser, "
                         + "You can copy the credentials to use on Mail.tm official website. "
                         + "Please note, the password cannot be reset or changed."
                    )
                        .frame(width: 400)
                        .padding()
                }
            }
            .padding(.bottom, 4)
            
            HStack {
                KeyView(key: "Status")
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(isActive ? .green : .red)
                Text(isActive ? "Active" : "InActive")
                    .lineLimit(1)
                if (!isActive) {
                    Spacer()
                    Button {
                        refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                    }
                }
            }
            
            HStack {
                KeyView(key: "Address")
                Text(address)
                    .lineLimit(1)
                
                Spacer()
                
                Button {
                    controller.copyStringToPasteboard(value: address)
                } label: {
                    Image(systemName: "doc.on.doc.fill")
                }
                
            }
            
            HStack {
                KeyView(key: "Password")
                Text(password)
                    .blur(radius: isPasswordVisible ? 0 : 3)
                    .lineLimit(1)
                    .onHover { isHovering in
                        withAnimation {
                            isPasswordVisible = isHovering
                        }
                    }
                
                Spacer()
                
                Button {
                    controller.copyStringToPasteboard(value: password)
                } label: {
                    Image(systemName: "doc.on.doc.fill")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(6)
    }
}

fileprivate struct KeyView: View {
    
    var key: String
    
    var body: some View {
        Text("\(key):")
            .fixedSize()
            .lineLimit(1)
            .font(.headline)
            
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView(isActive: true,
                        address: "Address",
                        password: "Password") {
            print("Refresh...")
        }
        .previewLayout(.fixed(width: 400, height: 500))
        
        AccountInfoView(isActive: false,
                        address: "Address",
                        password: "Password") {
            print("Refresh...")
        }
        .previewLayout(.fixed(width: 400, height: 500))
    }
}
