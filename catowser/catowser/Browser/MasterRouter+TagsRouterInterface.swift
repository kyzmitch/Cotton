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
        tagsSiteDataSource = .instagram(nodes)
        linkTagsController.setLinks(nodes.count, for: .video)
        updateDownloadsViews()
    }

    func openTagsFor(html tags: [HTMLVideoTag]) {
        tagsSiteDataSource = .htmlVideos(tags)
        linkTagsController.setLinks(tags.count, for: .video)
        updateDownloadsViews()
    }

    func closeTags() {
        tagsSiteDataSource = nil
        hideFilesGreedIfNeeded()
        hideLinkTagsController()
        filesGreedController.clearFiles()
        linkTagsController.clearLinks()
    }
}
