//
//  ProgressResponse.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 09/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

extension HttpKit {
    public enum ProgressResponse<T> {
        case progress(Progress)
        case complete(T)
    }
}
