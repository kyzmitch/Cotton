//
//  DownloadFacade.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 08/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire

public protocol Downloable {
    var url: URL { get }
    var fileName: String { get }
}

extension CoreBrowser {
    public enum FileSaveLocation {
        case globalGallery
        case sandboxFiles
    }
}

extension CoreBrowser {
    public final class DownloadFacade {
        static let shared = DownloadFacade()

        private init() {}

        typealias DownloadComplete = (Result<Data>) -> Void
    }
}

extension CoreBrowser.DownloadFacade {
    /// Sends download request and saves file.
    ///
    /// - Parameter file: All info about remote file and info about how it should be saved.
    /// - Parameter progressHandler: Use to track traffic progress.
    /// - Parameter completeHandler: Use to track error or success of download.
    func download(file: Downloable, progressHandler: @escaping Request.ProgressHandler, completeHandler: @escaping DownloadComplete) {
        let destination: DownloadRequest.DownloadFileDestination = filePath(name: file.fileName)
        let request = Alamofire.download(file.url, method: .get, to: destination)
        request
            .downloadProgress(queue: .main, closure: progressHandler)
            .responseData(queue: nil) { response in

        }

    }
}

fileprivate extension CoreBrowser.DownloadFacade {
    /// Path to temporary file to not waste RAM
    func filePath(name: String) -> DownloadRequest.DownloadFileDestination {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(name)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        return destination
    }
}
