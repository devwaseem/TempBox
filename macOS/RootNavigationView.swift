//
//  RootNavigationView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

struct RootNavigationView: View {
    
    @EnvironmentObject var appController: AppController

    var body: some View {
        NavigationView {
            SidebarView()
                .frame(minWidth: 250)

            InboxView()
                .frame(minWidth: 500)

            MessageDetailView()
                .frame(minWidth: 500)

        }
        .frame(minWidth: 1000, minHeight: 600, idealHeight: 800)
        .alert(isPresented: $appController.showError, content: {
            Alert(title: Text(appController.errorMessage), message: nil, dismissButton: .default(Text("OK"), action: {
                appController.showError = false
            }))
        })
        
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}
