//
//  RedirectProtector.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 6/17/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

// Handling redirects to sites with Advertises
// eg first request could be to some page on original site  https://xxx/ad_detail.html
// after that it redirects to
// https://ads.exosrv.com/iframe.php?
// or
// https://crptgate.com/pu/?

public struct RedirectProtector {
    private let currentHost: String
    private let pendingHost: String
    
    public init?(current: URL, next: URL) {
        guard let hostC = current.host else { return nil }
        guard let hostP = next.host else { return nil }
        currentHost = hostC
        pendingHost = hostP
    }
    
    public var isPendingSame: Bool {
        return pendingHost == currentHost || pendingHost.contains(currentHost)
    }
    
    public var shouldCancelRedirect: Bool {
        guard !isPendingSame else {
            return false
        }
        
        guard InMemoryRedirectsList.shared.isBlacklisted(currentHost) else {
            // e.g. (exempli gratia) if original host was google.com
            return false
        }
        
        guard !InMemoryRedirectsList.shared.isAllowed(pendingHost) else {
            return false
        }
        return true
    }
}
