//
//  Server.swift
//  ServerChecker
//
//  Created by Kyle Kim on 2022/12/28.
//

import Foundation
import SwiftUI


struct Server : Codable {
    var name : String
    var server : String
    var status : ServerStatus
    
    init(name: String, server : String, status : ServerStatus) {
        self.name = name
        self.server  = server
        self.status = status
    }
}

enum ServerStatus : Codable {
    case connected
    case disconnected
    case standBy
    
    var color: Color {
        switch self {
        case .connected:
            return .green
        case .disconnected:
            return .red
        case .standBy:
            return .black
        }
    }
}

