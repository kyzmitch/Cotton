//
//  WebViewController+AsyncAwait.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/15/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import Foundation
import CoreHttpKit

extension WebViewController {
    @available(swift 5.5)
    @MainActor
    @available(iOS 15.0, *)
    private func updateWebView(url: URL) async {
        if url.hasIPHost, let ipAddress = url.host {
            urlInfo = urlInfo.withIPAddress(ipAddress: ipAddress)
        }
        
        webView.load(URLRequest(url: url))
    }
    
    @available(swift 5.5)
    @available(iOS 15.0, *)
    func aaResolveDomainName(url: URL) async {
        dnsRequestTaskHandler?.cancel()
        let taskHandler = Task.detached(priority: .userInitiated) { [weak self] () -> URL in
            guard let self = self else {
                throw AppError.zombieSelf
            }
            let finalURL = try await self.dnsClient.aaResolvedDomainName(in: url)
            return finalURL
        }
        dnsRequestTaskHandler = taskHandler
        do {
            let finalURL = try await taskHandler.value
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
