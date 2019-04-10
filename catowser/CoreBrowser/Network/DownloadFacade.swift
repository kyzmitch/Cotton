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

        fileprivate let appGroupIdentifier = "group.com.ae.cotton-browser"

        private init() {}
    }
}

extension CoreBrowser.DownloadFacade {
    public typealias DownloadWithProgressSignalProducer = SignalProducer<CoreBrowser.ProgressResponse<Void>, DownloadError>

    /// Sends download request and saves file
    ///
    /// - Parameter file: All info about remote file and info about how it should be saved
    /// - Parameter location: Where to save the file
    /// - Returns: Signal Producer with progress
    public func download(file: Downloadable, saveTo location: CoreBrowser.FileSaveLocation) -> DownloadWithProgressSignalProducer {
        let producer = DownloadWithProgressSignalProducer { [weak self] (observer, _) in
            guard let `self` = self else {
                observer.send(error: .zombyInstance)
                return
            }

            let destination: DownloadRequest.DownloadFileDestination
            // You can't participate in the files app (or iTunes File Sharing)
            // if you don't store your files in the Documents folder.

            if let sandboxDestination = try? self.sandboxDestination(from: file.fileName) {
                destination = sandboxDestination
            } else {
                observer.send(error: .noDocumentsDirectory)
                return
            }

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
        case noDocumentsDirectory
        case noAppGroupDirectory
        case failedCreateFileProviderFolder
        case noCorrectDownloadDestination
        case failedExcludeFromBackup(Error)
        case networkError(Error)

        public var description: String {
            switch self {
            case .zombyInstance:
                return "zomby instance of DownloadFacade"
            case .noDocumentsDirectory:
                return "No documents directory"
            case .noAppGroupDirectory:
                return "No app group"
            case .failedCreateFileProviderFolder:
                return "Failed create folder"
            case .failedExcludeFromBackup(let error):
                return "failed to exclude download url from backup: \(error)"
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
    func sandboxDestination(from name: String) throws -> DownloadRequest.DownloadFileDestination {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        assert(urls.count != 0, "Failed to find documents directory")
        guard let documentsURL = urls.first else {
            throw DownloadError.noDocumentsDirectory
        }
        return documentsURL.destination(using: name)
    }

    func groupDestination(from name: String) throws -> DownloadRequest.DownloadFileDestination {
        let fileManager = FileManager.default

        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw DownloadError.noAppGroupDirectory
        }
        let storagePathUrl = groupURL.appendingPathComponent("File Provider Storage")
        let storagePath = storagePathUrl.path

        if !fileManager.fileExists(atPath: storagePath) {
            do {
                try fileManager.createDirectory(atPath: storagePath,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
            } catch let error {
                print("error creating filepath: \(error)")
                throw DownloadError.failedCreateFileProviderFolder
            }
        }
        return storagePathUrl.destination(using: name)
    }
}

fileprivate extension URL {
    func destination(using name: String) -> DownloadRequest.DownloadFileDestination {
        let fileURL = self.appendingPathComponent(name)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        return destination
    }
}
