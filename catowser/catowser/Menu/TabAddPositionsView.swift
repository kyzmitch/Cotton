//
//  TabAddPositionsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/30/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif
import CoreBrowser

/// Declare string representation for CoreBrowser enum
/// in host app to use localized strings.
extension AddedTabPosition: CustomStringConvertible {
    public var description: String {
        let key: String
        
        switch self {
        case .listEnd:
            key = "txt_tab_add_list_end"
        case .afterSelected:
            key = "txt_tab_add_after_selected"
        }
        return NSLocalizedString(key, comment: "")
    }
}

extension AddedTabPosition: Identifiable {
    public var id: RawValue {
        return self.rawValue
    }
    
    // swiftlint:disable:next type_name
    public typealias ID = RawValue
}

@available(iOS 13.0, *)
struct TabAddPositionsView: View {
    private let dataSource = AddedTabPosition.allCases
    
    private let viewTitle = NSLocalizedString("ttl_tab_positions", comment: "")
    
    var body: some View {
        NavigationView {
            List(dataSource) { position in
                Text(position.description)
            }
            .navigationBarTitle(Text(verbatim: viewTitle))
        }
    }
}

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0, *)
struct TabAddPositionsView_Previews: PreviewProvider {
    static var previews: some View {
        TabAddPositionsView()
    }
}
#endif
