//
//  AddAccountWindow.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI
import MailTMSwift

struct AddAccountWindow: View {

    @ObservedObject var controller: AddAccountViewController

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("New Address")
                    .font(.title)
                    .padding(.bottom)
                HStack {
                    TextField("Address", text: $controller.addressText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    DomainView(isLoading: controller.isDomainsLoading,
                               availableDomains: controller.availableDomains,
                               selectedDomain: $controller.selectedDomain)

                }
                .disabled(controller.isCreatingAccount)

                PasswordView(randomPassword: $controller.shouldGenerateRandomPassword,
                              password: $controller.passwordText)
                    .padding(.top)
                    .disabled(controller.isCreatingAccount)
            }
            .padding()
            HStack {
                Button(action: {
                    controller.closeAddAccountWindow()
                }, label: {
                    Text("Cancel")
                })
                    .keyboardShortcut(.cancelAction)
                    .disabled(controller.isCreatingAccount)
                Spacer()
                Button(action: {
                    controller.generateRandomAddress()
                }, label: {
                    Text("Random address")
                })
                    .disabled(controller.isCreatingAccount)
                Button(action: {
                    controller.createNewAddress()
                }, label: {
                    if controller.isCreatingAccount {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Create")
                    }
                })
                    .disabled(!controller.canCreate)
                    .keyboardShortcut(.defaultAction)

            }
            .padding()
        }
        .alert(isPresented: $controller.showErrorAlert, content: {
            Alert(title: Text(controller.errorMessage), message: nil, dismissButton: .default(Text("OK"), action: {
                controller.showErrorAlert = false
            }))
        })
        .padding()
        .frame(width: 600)

    }

}

private struct DomainView: View {

    var isLoading: Bool
    var availableDomains: [String]
    @Binding var selectedDomain: String

    var body: some View {
        HStack {
            Text("@")
            if isLoading {
                loadingView
            } else {
                Picker(selection: $selectedDomain, label: EmptyView(), content: {
                    ForEach(availableDomains, id: \.self) { domain in
                        Text(domain)
                            .tag(domain)
                    }
                })
            }
        }
    }

    var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .controlSize(.small)
            Spacer()
        }
        .padding(.top)
    }

}

private struct PasswordView: View {

    @Binding var randomPassword: Bool
    @Binding var password: String

    var body: some View {
        if !randomPassword {
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        Toggle("Generate random password", isOn: $randomPassword)
    }

}

struct AddAccountWindow_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountWindow(controller: .init())
    }
}
