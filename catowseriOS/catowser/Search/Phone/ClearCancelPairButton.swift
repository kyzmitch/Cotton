//
//  ClearCancelPairButton.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/25/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

final class ClearCancelButtonViewModel {
    @Published var clearTapped: Void
    @Published var cancelTapped: Void
    
    init() {
        clearTapped = ()
        cancelTapped = ()
    }
}

struct ClearCancelPairButton: View {
    @Binding private var showClearButton: Bool
    private let vm: ClearCancelButtonViewModel
    
    init(_ showClearButton: Binding<Bool>, _ vm: ClearCancelButtonViewModel) {
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
                vm.cancelTapped = ()
            }
            .foregroundColor(.gray)
        }
    }
}

private extension LocalizedStringKey {
    static let cancelButtonTtl: LocalizedStringKey = "ttl_common_cancel"
}
