//
//  HostsComparator.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 6/17/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit

// Handling redirects to sites with Advertises
// eg first request could be to some page on original site  https://xxx/ad_detail.html
// after that it redirects to
// https://ads.exosrv.com/iframe.php?
// or
// https://crptgate.com/pu/?

// TODO: move functionality to HttpKit Host type

public struct HostsComparator {
    private let currentHost: String
    private let pendingHost: String
    
    public init?(_ current: URL, _ next: URL) {
        guard let hostC = current.host else { return nil }
        guard let hostP = next.host else { return nil }
        currentHost = hostC
        pendingHost = hostP
    }
    
    public init(_ currentHost: HttpKit.Host, _ nextHost: String) {
        self.currentHost = currentHost.rawValue
        self.pendingHost = nextHost
    }
    
    public var isPendingSame: Bool {
        return pendingHost == currentHost || pendingHost.contains(currentHost)
    }
    
    public var shouldCancelRedirect: Bool {
        guard !isPendingSame else {
            return false
        }
        
        guard InMemoryRedirectsList.shared.isSupported(currentHost) else {
            // host is not supported by redirects list
            return false
        }
        
        guard !InMemoryRedirectsList.shared.isSupported(pendingHost) else {
            // same variation of host like it was "m.youtube.com"
            // and wants to change to "www.youtube.com"
            return false
        }
        
        guard !InMemoryRedirectsList.shared.isAllowed(pendingHost) else {
            return false
        }
        return true
    }
}
