//
//  JSONProtocol.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/22/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    func decode<T : Decodable>(dict: [String: Any]) throws -> T? {
        let data = try dict.toData()
        return try decode(T.self, from: data)
    }
}
