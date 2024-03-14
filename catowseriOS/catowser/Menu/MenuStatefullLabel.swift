//
//  MenuStatefullLabelView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 3/13/24.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import SwiftUI

struct MenuStatefullLabel: View {
    let menuLocalizationKey: String
    let menuCurrentValue: String
    
    init(_ menuLocalizationKey: String, _ menuCurrentValue: String) {
        self.menuLocalizationKey = menuLocalizationKey
        self.menuCurrentValue = menuCurrentValue
    }
    
    var body: some View {
        Text(LocalizedStringKey(menuLocalizationKey))
        Spacer()
        Text(verbatim: menuCurrentValue)
            .modifier(AlignTextRight())
    }
}

struct AlignTextRight: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .trailing)
            .multilineTextAlignment(.trailing)
    }
}

#Preview {
    MenuStatefullLabel(.appUIFrameworkTypeTxt, "Some value")
}
