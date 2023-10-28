//
//  TappableTextOverlayView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/25/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

final class TappableTextOverlayViewModel {
    @Published var tapped: Void
    
    init() {
        tapped = ()
    }
}

struct TappableTextOverlayView: View {
    private let textContent: String
    private let vm: TappableTextOverlayViewModel
    
    init(_ textContent: String, _ vm: TappableTextOverlayViewModel) {
        self.textContent = textContent
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

#if DEBUG
struct TappableTextOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        let textContent = "example.com"
        let vm: TappableTextOverlayViewModel = .init()
        TappableTextOverlayView(textContent, vm)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    }
}
#endif
