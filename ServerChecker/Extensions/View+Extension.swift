//
//  View+Extension.swift
//  ServerChecker
//
//  Created by Kyle Kim on 2022/12/28.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func isHidden(_ hide: Bool) -> some View {
        if hide {
            hidden()
        } else {
            self
        }
    }
}
