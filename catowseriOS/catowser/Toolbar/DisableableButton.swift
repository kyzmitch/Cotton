//
//  DisableableButton.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/26/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

@MainActor
struct DisableableButton: View {
    private let disabled: Bool
    private let imageName: String
    private let onTap: () -> Void
    
    init(_ imageName: String, _ disabled: Bool, _ onTap: @MainActor @escaping () -> Void) {
        self.imageName = imageName
        self.disabled = disabled
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
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
