//
//  WebView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 17/09/21.
//

import SwiftUI
import WebKit

struct WebView: View {
    var html: String

    var body: some View {
        WebViewWrapper(html: html)
    }
}

struct WebViewWrapper: NSViewRepresentable {
    let html: String

    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(html, baseURL: nil)
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(html: "<p>It works?</p>")
    }
}
