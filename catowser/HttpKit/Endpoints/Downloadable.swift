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
    
    public func fileAtDestination() -> URL? {
        do {
            let destination = try sandboxDestination()
            let dummyURL: URL = .init(fileURLWithPath: "")
            let dummyResponse: HTTPURLResponse = .init()
            let fileURL: URL = destination(dummyURL, dummyResponse).destinationURL
            let isExist = FileManager.default.fileExists(atPath: fileURL.path)
            return isExist ? fileURL : nil
        } catch {
            return nil
        }
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
        let nameWithoutSpaces = name.replacingOccurrences(of: " ", with: "_")
        let fileURL = self.appendingPathComponent(nameWithoutSpaces, isDirectory: true)
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
        case noHttpHeadersInResponse
        case noContentLengthHeader
        case stringToIntFailed
        case urlRequestInit(Error)

        public var description: String {
            switch self {
            case .failedExcludeFromBackup(let error):
                return "failed to exclude download url from backup: \(error)"
            case .networkError(let error):
                return "network error: \(error)"
            case .urlRequestInit(let error):
                return "failed to construct URLRequest: \(error)"
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
    public typealias RemoteFileInfoProducer = SignalProducer<Int, DownloadError>
    
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
    
    /**
     Fetches info of remote file like file size which expect to be dowloaded.
     https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Length
     The Content-Length entity header indicates the size of the entity-body, in bytes, sent to the recipient.
     https://tools.ietf.org/html/rfc7230#section-3.3.2
     A server MAY send a Content-Length header field in a response to a
     HEAD request.
     
     */
    public static func fetchRemoteResourceInfo(url: URL) -> RemoteFileInfoProducer {
        let producer = RemoteFileInfoProducer { (observer, _) in
            let request: URLRequest
            do {
                request = try URLRequest(url: url, method: .head)
            } catch {
                observer.send(error: .urlRequestInit(error))
                return
            }
            AF.request(request).response { (afResponse) in
                if let networkError = afResponse.error {
                    observer.send(error: .networkError(networkError))
                    return
                }
                guard let headers = afResponse.response?.headers else {
                    observer.send(error: .noHttpHeadersInResponse)
                    return
                }
                let key = HttpHeader.contentLength(0).key
                guard let contentLengthValue = headers.value(for: key) else {
                    observer.send(error: .noContentLengthHeader)
                    return
                }
                guard let contentLength = Int(contentLengthValue, radix: 10) else {
                    observer.send(error: .stringToIntFailed)
                    return
                }
                observer.send(value: contentLength)
                observer.sendCompleted()
            }
        }
        return producer
    }
}
