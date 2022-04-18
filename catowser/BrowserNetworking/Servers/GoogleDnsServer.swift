//
//  GoogleDnsServer.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 11/9/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreHttpKit

public class GoogleDnsServer: ServerDescription {
    public override var domain: String {
        return "dns.google"
    }
    public override var hostString: String {
        return domain
    }
}
