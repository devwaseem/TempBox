//
//  AccountInfoView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 03/10/21.
//

import SwiftUI

struct AccountInfoView: View {
    
    @StateObject var controller = AccountInfoViewController()
    @State var isPasswordVisible = false
    
    var isActive: Bool
    var address: String
    var password: String
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text("Status: ")
                    .fixedSize()
                    .lineLimit(1)
                    .font(.headline)
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(isActive ? .green : .red)
                Text(isActive ? "Active" : "InActive")
                    .lineLimit(1)
            }
            
            HStack {
                Text("Address: ")
                    .fixedSize()
                    .lineLimit(1)
                    .font(.headline)
                Text(address)
                    .lineLimit(1)
                
                Button {
                    controller.copyStringToPasteboard(value: address)
                } label: {
                    Image(systemName: "doc.on.doc.fill")
                }
                Spacer()
            }
            
            HStack {
                Text("Password: ")
                    .fixedSize()
                    .lineLimit(1)
                    .font(.headline)
                Text(password)
                    .blur(radius: isPasswordVisible ? 0 : 3)
                    .lineLimit(1)
                    .onTapGesture {
                        withAnimation {
                            isPasswordVisible.toggle()
                        }
                    }
                
                Button {
                    controller.copyStringToPasteboard(value: password)
                } label: {
                    Image(systemName: "doc.on.doc.fill")
                }
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(6)
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView(isActive: true,
                        address: "Address",
                        password: "Password")
            .previewLayout(.fixed(width: 400, height: 500))
        
        AccountInfoView(isActive: false,
                        address: "Address",
                        password: "Password")
            .previewLayout(.fixed(width: 400, height: 500))
    }
}
