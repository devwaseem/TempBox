//
//  RootNavigationView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

struct RootNavigationView: View {

    @StateObject var appController = AppController()

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
        .environmentObject(appController)
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}
