//
//  APIService.swift
//  ServerChecker
//
//  Created by Kyle Kim on 2022/12/28.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    func updateServer(server: Server) -> AnyPublisher<Bool, Never> 
}

class APIService: APIServiceProtocol {
    func updateServer(server: Server) -> AnyPublisher<Bool, Never> {
        let url = URL(string: server.server )!
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
            .receive(on: RunLoop.main)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
