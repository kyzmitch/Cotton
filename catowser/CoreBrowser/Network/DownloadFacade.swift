//
//  DownloadFacade.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 08/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

public protocol Downloadable {
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
        public static let shared = DownloadFacade()

        private init() {}
    }
}

extension CoreBrowser.DownloadFacade {
    public typealias DownloadWithProgressSignalProducer = SignalProducer<CoreBrowser.ProgressResponse<Void>, DownloadError>

    /// Sends download request and saves file.
    ///
    /// - Parameter file: All info about remote file and info about how it should be saved.
    /// - Returns: Signal Producer with progress
    public func download(file: Downloadable, saveTo location: CoreBrowser.FileSaveLocation) -> DownloadWithProgressSignalProducer {
        let producer = DownloadWithProgressSignalProducer { [weak self] (observer, _) in
            guard let `self` = self else {
                observer.send(error: .zombyInstance)
                return
            }

            let destination = self.downloadDestination(from: file.fileName)
            let request = Alamofire.download(file.url, method: .get, to: destination)

            request.downloadProgress(queue: .main, closure: { (progress) in
                observer.send(value: .progress(progress))
            }).responseData(queue: nil) { (response: DownloadResponse<Data>) in
                switch response.result {
                case .success(_):
                    guard var destinationURL = response.destinationURL else {
                        observer.send(error: .noCorrectDownloadDestination)
                        return
                    }
                    var values = URLResourceValues()
                    values.isExcludedFromBackup = true
                    do {
                        try destinationURL.setResourceValues(values)
                    }
                    catch {
                        print("Failed to exclude from backup: \(error)")
                        observer.send(error: .failedExcludeFromBackup(error))
                    }

                    let void: (Void) = ()
                    observer.send(value: .complete(void))
                    observer.sendCompleted()
                    break
                case .failure(let error):
                    observer.send(error: .networkError(error))
                }
            }
        }

        return producer
    }
}

extension CoreBrowser.DownloadFacade {
    public enum DownloadError: Error, CustomStringConvertible {
        case zombyInstance
        case noCorrectDownloadDestination
        case failedExcludeFromBackup(Error)
        case networkError(Error)

        public var description: String {
            switch self {
            case .zombyInstance:
                return "zomby instance of DownloadFacade"
            case .failedExcludeFromBackup(let error):
                return "failed to exlude download url from backup: \(error)"
            case .noCorrectDownloadDestination:
                return "download destination URL is empty"
            case .networkError(let error):
                return "network error: \(error)"
            }
        }
    }
}

fileprivate extension CoreBrowser.DownloadFacade {
    /// Path to temporary file to not waste RAM
    func downloadDestination(from name: String) -> DownloadRequest.DownloadFileDestination {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        assert(urls.count != 0, "Failed to find documents directory")

        let documentsURL = urls[0]
        var fileURL = documentsURL.appendingPathComponent(name)

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        return destination
    }
}
