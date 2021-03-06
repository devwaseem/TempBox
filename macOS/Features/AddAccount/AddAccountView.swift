//
//  AddAccountView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

struct AddAccountView: View {

    @State var isPickerWindowOpen = false
    @StateObject private var controller = AddAccountViewController()

    var body: some View {
        Button(action: controller.openAddAccountWindow, label: {
            VStack(alignment: .leading) {
                HStack {
                    Text("New Address")
                        .padding(.leading, 4)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(6)
            }
        })
        .buttonStyle(PlainButtonStyle())
        .keyboardShortcut(.init("a", modifiers: [.command]))
        .sheet(isPresented: $controller.isAddAccountWindowOpen) {
            AddAccountWindow(controller: controller)
        }
        .alert(item: $controller.alertMessage) { alertData in
            var messageText: Text?
            if let message = alertData.message {
                messageText = Text(message)
            }
            return Alert(title: Text(alertData.title), message: messageText, dismissButton: .default(Text("OK"), action: {
                controller.alertMessage = nil
            }))
        }
    }
}

struct AddAccountButton_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView()
    }
}
