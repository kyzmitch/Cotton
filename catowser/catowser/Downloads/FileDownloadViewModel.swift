//
//  FileDownloadViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 23/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import HttpKit

protocol FileDownloadDelegate: class {
    func didPressOpenFile(withLocal url: URL)
}

final class FileDownloadViewModel {
    fileprivate let downloadOutput = MutableProperty<DownloadState>(.initial)

    lazy var stateSignal: Signal<DownloadState, Never> = {
        return downloadOutput.signal
    }()

    fileprivate let batch: Downloadable

    weak var delegate: FileDownloadDelegate?

    init(with batch: Downloadable) {
        self.batch = batch
    }

    func download() {
        downloadOutput.value = .started
        
        HttpKit.DownloadFacade.shared.download(file: batch)
            .observe(on: QueueScheduler.main)
            .startWithResult { [weak self] (result) in
                guard let self = self else {
                    assertionFailure("Zomby self")
                    return
                }
                switch result {
                case .success(let value):
                    switch value {
                    case .progress(let progress):
                        let converted = CGFloat(progress.fractionCompleted)
                        self.downloadOutput.value = .in(progress: converted)
                    case .complete(let localURL):
                        self.downloadOutput.value = .finished(localURL)
                    }
                case .failure(let error):
                    print("download error: \(error)")
                    self.downloadOutput.value = .error(error)
                }
        }
    }

    enum DownloadState {
        case initial
        case started
        case `in`(progress: CGFloat)
        case finished(URL)
        case error(Error)
    }
}
