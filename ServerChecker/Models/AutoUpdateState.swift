//
//  AutoUpdateState.swift
//  ServerChecker
//
//  Created by Kyle Kim on 2023/01/28.
//

import Foundation
import SwiftUI

enum AutoUpdateState {
    case on
    case off
    
    var imageName: String {
        switch self {
        case .on:
            return "stop.fill"
        case .off:
            return "play.fill"
        }
    }
    
    var imageColor : Color {
        switch self {
        case .on:
            return .red
        case .off:
            return .green
        }
    }
    
    mutating func switchState() {
        switch self {
        case .on:
            self = .off
        case .off:
            self = .on
        }
    }
}
