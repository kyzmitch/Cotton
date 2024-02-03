//
//  DownloadPanelPresenter.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/5/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import UIKit

/// Used by tablet search bar on Tablet and by toolbar on Phone
protocol DownloadPanelPresenter: AnyObject {
    func didPressDownloads(to hide: Bool)
    func didPressTabletLayoutDownloads(from sourceView: UIView, and sourceRect: CGRect)
}
