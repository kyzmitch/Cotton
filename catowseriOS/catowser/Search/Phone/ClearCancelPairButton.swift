//
//  ClearCancelPairButton.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/25/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI

final class ClearCancelButtonViewModel: ObservableObject {
    @Published var clearTapped: Void
    @Published var cancelTapped: Void

    init() {
        clearTapped = ()
        cancelTapped = ()
    }
}

struct ClearCancelPairButton: View {
    private let showClearButton: Bool
    @ObservedObject private var vm: ClearCancelButtonViewModel

    init(_ showClearButton: Bool, _ vm: ClearCancelButtonViewModel) {
        self.showClearButton = showClearButton
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

#if DEBUG
struct ClearCancelPairButton_Previews: PreviewProvider {
    static var previews: some View {
        let showClearButton = true
        let vm: ClearCancelButtonViewModel = .init()
        ClearCancelPairButton(showClearButton, vm)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
#endif
