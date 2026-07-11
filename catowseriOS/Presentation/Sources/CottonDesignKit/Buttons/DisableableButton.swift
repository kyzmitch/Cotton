//
//  DisableableButton.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/26/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI
import ViewsBase

/// Disableable button
@MainActor
public struct DisableableButton: View {
    private let disabled: Bool
    private let imageName: String
    private let onTap: @MainActor () -> Void

    /// Init
    public init(
        _ imageName: String,
        _ disabled: Bool,
        _ onTap: @escaping @MainActor () -> Void
    ) {
        self.imageName = imageName
        self.disabled = disabled
        self.onTap = onTap
    }

    /// View body
    public var body: some View {
        Button(action: onTap) {
            Image(imageName)
        }
        .disabled(disabled)
        .opacity(disabled ? ThemeProvider.disabledOpacity : 1)
    }
}

struct DisableableButton_Previews: PreviewProvider {
    static var previews: some View {
        let disabled = false
        DisableableButton("square.and.arrow.up", disabled) {
            print("onTap")
        }
    }
}
