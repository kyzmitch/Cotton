//
//  WebViewController+AsyncAwait.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/15/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import Foundation
import HttpKit
#if canImport(_Concurrency)
// this won't be needed after Swift 5.5 will be released
import _Concurrency
#endif

extension WebViewController {
    @available(swift 5.5)
    @MainActor
    @available(iOS 15.0, *)
    private func updateWebView(url: URL) async {
        urlInfo.ipAddress = url.host
        webView.load(URLRequest(url: url))
    }
    
    @available(swift 5.5)
    @available(iOS 15.0, *)
    func aaResolveDomainName(url: URL) async {
        dnsRequestTaskHandler?.cancel()
        let taskHandler = detach(priority: .userInitiated) { [weak self] () -> URL in
            guard let self = self else {
                throw AppError.zombieSelf
            }
            let finalURL = await try self.dnsClient.aaResolvedDomainName(in: url)
            return finalURL
        }
        dnsRequestTaskHandler = taskHandler
        do {
            let finalURL = await try taskHandler.get()
            guard finalURL.hasIPHost else {
                print("Alert - host wasn't replaced on IP address after operation")
                return
            }
            await updateWebView(url: finalURL)
        } catch {
            print("Fail to resolve host with DNS: \(error.localizedDescription)")
        }
    }
}

#endif
