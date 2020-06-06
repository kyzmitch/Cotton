//
//  MasterRouter+TagsRouterInterface.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import JSPlugins

extension MasterRouter: TagsRouterInterface {
    func openTagsFor(instagram nodes: [InstagramVideoNode]) {
        dataSource = .instagram(nodes)
        linkTagsController.setLinks(nodes.count, for: .video)
        updateDownloadsViews()
    }
    
    func openTagsFor(t4 video: T4Video) {
        dataSource = .t4(video)
        linkTagsController.setLinks(1, for: .video)
        updateDownloadsViews()
    }

    func openTagsFor(html tags: [HTMLVideoTag]) {
        dataSource = .htmlVideos(tags)
        linkTagsController.setLinks(tags.count, for: .video)
        updateDownloadsViews()
    }

    func closeTags() {
        dataSource = nil
        hideFilesGreedIfNeeded()
        hideLinkTagsController()
        filesGreedController.clearFiles()
        linkTagsController.clearLinks()
    }
}
