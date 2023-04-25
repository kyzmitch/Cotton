//
//  SearchBarOverlayView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/25/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

final class SearchBarOverlayViewModel {
    @Published var tapped: Void
    
    init() {
        tapped = ()
    }
}

struct SearchBarOverlayView: View {
    @Binding private var textContent: String
    private let vm: SearchBarOverlayViewModel
    
    init(_ textContent: Binding<String>, _ vm: SearchBarOverlayViewModel) {
        _textContent = textContent
        self.vm = vm
    }
    
    var body: some View {
        Text(verbatim: textContent)
            .background(Color(.secondarySystemBackground))
            .frame(maxWidth: .infinity)
            .scaledToFill()
            .onTapGesture {
                vm.tapped = ()
            }
    }
}
