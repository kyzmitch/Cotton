//
//  DisableableButton.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/26/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct DisableableButton: View {
    @Binding private var disabled: Bool
    private let imageName: String
    private let onTap: () -> Void
    
    init(_ imageName: String, _ disabled: Binding<Bool>, _ onTap: @escaping () -> Void) {
        self.imageName = imageName
        _disabled = disabled
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
        let disabled: Binding<Bool> = .init {
            false
        } set: { _ in
            //
        }
        DisableableButton("square.and.arrow.up", disabled) {
            print("onTap")
        }
    }
}
