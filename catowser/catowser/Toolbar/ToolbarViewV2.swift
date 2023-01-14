//
//  ToolbarViewV2.swift
//  catowser
//
//  Created by Andrey Ermoshin on 03.01.2023.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-toolbar-and-add-buttons-to-it

struct ToolbarViewV2: View {
    var body: some View {
        NavigationView {
            
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image("nav-back")
                }

            }
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image("nav-forward")
                }
            }
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image("nav-refresh")
                }
            }
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .principal) {
                Button(role: nil) {
                    
                } label: {
                    Image("nav-downloads")
                }
            }
        }
    }
}

#if DEBUG
struct ToolbarViewV2_Previews: PreviewProvider {
    static var previews: some View {
        // Doesn't work in preview!
        ToolbarViewV2()
    }
}
#endif
