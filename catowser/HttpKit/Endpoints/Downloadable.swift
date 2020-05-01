//
//  Downloadable.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/22/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

public protocol Downloadable {
    var url: URL { get }
    var fileName: String { get }
    var excludeFromBackup: Bool { get }
}

extension Downloadable {
    public var excludeFromBackup: Bool {
        return true
    }
    /// Path to temporary file to not waste RAM.
    /// You can't participate in the files app (or iTunes File Sharing)
    /// if you don't store your files in the Documents folder.
    func sandboxDestination() throws -> DownloadRequest.Destination {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        assert(urls.count != 0, "Failed to find documents directory")
        guard let documentsURL = urls.first else {
            throw HttpKit.DownloadError.noDocumentsDirectory
        }
        return documentsURL.destination(using: fileName)
    }
}

fileprivate extension URL {
    func destination(using name: String) -> DownloadRequest.Destination {
        let fileURL = self.appendingPathComponent(name)
        let destination: DownloadRequest.Destination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        return destination
    }
}

extension HttpKit {
    public enum ProgressResponse<T> {
        case progress(Progress)
        case complete(T)
    }
}

extension HttpKit {
    public enum DownloadError: LocalizedError {
        case zombyInstance
        case noDocumentsDirectory
        case noAppGroupDirectory
        case failedCreateFileProviderFolder
        case noCorrectDownloadDestination
        case failedExcludeFromBackup(Error)
        case networkError(Error)

        public var description: String {
            switch self {
            case .failedExcludeFromBackup(let error):
                return "failed to exclude download url from backup: \(error)"
            case .networkError(let error):
                return "network error: \(error)"
            default:
                return "\(self)"
            }
        }
    }
}

extension HttpKit {
    fileprivate var appGroupIdentifier: String {
        "group.com.ae.cotton-browser"
    }
    
    public typealias FileDownloadProducer = SignalProducer<ProgressResponse<URL>, DownloadError>
    
    /// Sends download request for remote file
    ///
    /// - Parameter file: All info about remote file and info about how it should be saved
    /// - Returns: Signal Producer with progress
    public static func download(file: Downloadable) -> FileDownloadProducer {
        let producer = FileDownloadProducer { (observer, _) in
            let destination: DownloadRequest.Destination

            do {
                destination = try file.sandboxDestination()
            } catch {
                observer.send(error: .noDocumentsDirectory)
                return
            }

            let request = AF.download(file.url, method: .get, to: destination)
            request.downloadProgress(queue: .main) { (progress) in
                observer.send(value: .progress(progress))
            }.responseData(queue: .main) { (response) in
                switch response.result {
                case .success:
                    guard var destinationURL = response.fileURL else {
                        observer.send(error: .noCorrectDownloadDestination)
                        return
                    }
                    var values = URLResourceValues()
                    values.isExcludedFromBackup = file.excludeFromBackup
                    do {
                        try destinationURL.setResourceValues(values)
                    } catch {
                        observer.send(error: .failedExcludeFromBackup(error))
                        return
                    }

                    observer.send(value: .complete(destinationURL))
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: .networkError(error))
                }
            }
        }

        return producer
    }
}
