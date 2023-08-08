//
//  WebViewLoadingErrorHandler.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/2/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import WebKit
import UIKit

/**
Called when an error occurs while the web view is loading content.
In our case it happens on auth challenge fail when entered domain name doesn't match with one
in server SSL certificate or when ip address was used for DNS over HTTPS and it can't
be equal with domain names from SSL certificate.
*/

/**
 If this is an invalid certificate, show a certificate error allowing the
 user to go back or continue.
 */

final class WebViewLoadingErrorHandler {
    let error: NSError
    let webView: WKWebView
    let url: URL?
    
    init(_ error: Error, _ webView: WKWebView) {
        self.error = error as NSError
        self.webView = webView
        self.url = webView.url
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func recover(_ presentationController: UIViewController) {
        // https://opensource.apple.com/source/libsecurity_ssl/libsecurity_ssl-36800/lib/SecureTransport.h
        var isTLSError = false
        var msg = error.localizedDescription
        
        switch (error.domain, error.code) {
        case (NSURLErrorDomain, NSURLErrorCancelled):
            return
        case (NSURLErrorDomain, -1202):
            isTLSError = true
        case (NSCocoaErrorDomain, NSUserCancelledError):
            // "The operation couldn't be completed. (Cocoa error 3072.)" - useless
            return
        case ("WebKitErrorDomain", WKError.webContentProcessTerminated.rawValue /* 102 */):
            print("WebContent process has crashed. Trying to reload to restart it.")
            /**
             TODO: for DoH case this should be improved, because currently it creates an infinit loop of reloading
             */
            webView.reload()
            return
        case (NSOSStatusErrorDomain, Int(errSSLProtocol)): /* -9800 */
            msg = NSLocalizedString("TLS protocol error", comment: "")
            isTLSError = true
        case (NSOSStatusErrorDomain, Int(errSSLNegotiation)): /* -9801 */
            msg = NSLocalizedString("TLS handshake failed", comment: "")
            isTLSError = true
        case (NSOSStatusErrorDomain, Int(errSSLXCertChainInvalid)): /* -9807 */
            let key = "TLS certificate chain verification error (self-signed certificate?)"
            msg = NSLocalizedString(key, comment: "")
            isTLSError = true
        case (NSOSStatusErrorDomain, -1202):
            isTLSError = true
        default:
            break
        }

        if !isTLSError {
            msg += "\n(code: \(error.code), domain: \(error.domain))"
        }

        let urlString = error.userInfo[NSURLErrorFailingURLStringErrorKey] as? String

        if let url = urlString {
            msg += "\n\n\(url)"
        }

        /**
         TODO: Temporarily not showing the alert views,
         because there is a case when they could be showed infinitly on DoH case
         */
    }
}
