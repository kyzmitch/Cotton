//
//  SearchBarCancelButton.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/25/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

final class SearchBarCancelViewModel {
    @Published var clearTapped: Void
    @Published var cancelTapped: Void
    
    init() {
        clearTapped = ()
        cancelTapped = ()
    }
}

struct SearchBarCancelButton: View {
    @Binding private var showClearButton: Bool
    private let vm: SearchBarCancelViewModel
    
    init(_ showClearButton: Binding<Bool>, _ vm: SearchBarCancelViewModel) {
        _showClearButton = showClearButton
        self.vm = vm
    }
    
    var body: some View {
        HStack {
            if showClearButton {
                Button {
                    vm.clearTapped = ()
                } label: {
                    Image(systemName: "x.circle.fill")
                }
            }
            Button(.cancelButtonTtl) {
                vm.clearTapped = ()
            }
            .foregroundColor(.gray)
        }
    }
}

private extension LocalizedStringKey {
    static let cancelButtonTtl: LocalizedStringKey = "ttl_common_cancel"
}
