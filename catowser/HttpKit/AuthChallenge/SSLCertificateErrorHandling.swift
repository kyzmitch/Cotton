//
//  SSLCertificateErrorHandling.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 5/2/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    /**
     Regardless of cause, `NSURLErrorServerCertificateUntrusted` is currently returned in all cases.
     Check the other cases in case this gets fixed in the future.
     */
    public static let certErrors = [
        NSURLErrorServerCertificateUntrusted,
        NSURLErrorServerCertificateHasBadDate,
        NSURLErrorServerCertificateHasUnknownRoot,
        NSURLErrorServerCertificateNotYetValid
    ]
}
