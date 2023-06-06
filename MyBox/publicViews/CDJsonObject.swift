//
//  CDJSONObject.swift
//  MyBox
//
//  Created by dong chang on 2023/3/2.
//  Copyright © 2023 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation

public struct CDJsonObject {
    public enum JSONError:Error,Equatable,Hashable{
        case notUTF8EncodableString
        case invalidJSONInput
        case fileNotFound
    }
    
    public let jsonString:String
    public let jsonData:Data
    public let jsonDictionary:[String:Any]?
    public let jsonArray:[Any]?
    
    public init(jsonData:Data) throws{
        guard let string = String(data: jsonData, encoding: .utf8) else{
            throw JSONError.notUTF8EncodableString
        }
        let object = try JSONSerialization.jsonObject(with: jsonData)
        self.jsonData = jsonData
        jsonString = string
        jsonDictionary = object as? [String:Any]
        jsonArray = object as? [Any]
    }
    
    public init(jsonString:String) throws{
        try self.init(jsonData: Data(jsonString.utf8))
    }
    
    public init(jsonDictionary: [String:Any]) throws{
        guard JSONSerialization.isValidJSONObject(jsonDictionary) else{
            throw JSONError.invalidJSONInput
        }
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary)
        try self.init(jsonData: jsonData)
    }
    
    public init(jsonArray:[Any]) throws{
        guard JSONSerialization.isValidJSONObject(jsonArray) else{
            throw JSONError.invalidJSONInput
        }
        let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
        try self.init(jsonData: jsonData)
    }
    
    public init(url:URL) throws{
        let jsonData = try Data(contentsOf: url)
        try self.init(jsonData: jsonData)
    }
    
    public init(jsonFile fileName:String, InBundle bundle:Bundle = .main) throws{
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else{
            throw JSONError.fileNotFound
        }
        try self.init(url: url)
    }
    
    public init<T>(from encodable:T, dateEncodingStrategy:JSONEncoder.DateEncodingStrategy = .iso8601) throws where T:Encodable{
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        let jsonData = try encoder.encode(encodable)
        try self.init(jsonData: jsonData)
    }
    
    public func decoded<T>(dateDecodingStrategy:JSONDecoder.DateDecodingStrategy = .iso8601) throws -> T where T:Decodable{
        try decoded(as: T.self, dateDecodingStrategy: dateDecodingStrategy)
    }
    
    public func decoded<T>(as type: T.Type, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) throws -> T where T:Decodable{
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = dateDecodingStrategy
        return try jsonDecoder.decode(type, from: jsonData)
    }
}
