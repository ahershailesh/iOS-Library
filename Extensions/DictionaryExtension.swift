//
//  DictionaryExtension.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/22/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//

import Foundation

extension Dictionary {
    func toData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    
    func toJSON() throws -> String? {
        let data = try self.toData()
        return String(bytes: data, encoding: .utf8)
    }
}
