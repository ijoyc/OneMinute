//
//  KeychainStorage.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/13.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

class KeychainStorage : StorageService {
  
  static let shared = KeychainStorage()
  
  private init() {}
  
  func setValue(_ value: String, for key: String) throws {
    guard let encoded = value.data(using: .utf8) else {
      throw StorageError.string2DataConversionError
    }
    
    var query = makeQuery()
    query[String(kSecAttrAccount)] = key
    
    var status = SecItemCopyMatching(query as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      var attributesToUpdate: [String: Any] = [:]
      attributesToUpdate[String(kSecValueData)] = encoded
      status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
      if status != errSecSuccess {
        throw error(from: status)
      }
    case errSecItemNotFound:
      query[String(kSecValueData)] = encoded
      status = SecItemAdd(query as CFDictionary, nil)
      if status != errSecSuccess {
        throw error(from: status)
      }
    default:
      throw error(from: status)
    }
  }
  
  func value(for key: String) throws -> String? {
    var query = makeQuery()
    query[String(kSecMatchLimit)] = kSecMatchLimitOne
    query[String(kSecReturnAttributes)] = kCFBooleanTrue
    query[String(kSecReturnData)] = kCFBooleanTrue
    query[String(kSecAttrAccount)] = key
    
    var queryResult: AnyObject?
    let status = withUnsafeMutablePointer(to: &queryResult) {
      SecItemCopyMatching(query as CFDictionary, $0)
    }
    
    switch status {
    case errSecSuccess:
      guard
        let result = queryResult as? [String: Any],
        let encoded = result[String(kSecValueData)] as? Data,
        let value = String(data: encoded, encoding: .utf8) else {
        throw StorageError.data2StringConversionError
      }
      
      return value
    case errSecItemNotFound:
      return nil
    default:
      throw error(from: status)
    }
  }
  
  func removeValue(for key: String) throws {
    var query = makeQuery()
    query[String(kSecAttrAccount)] = key
    
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw error(from: status)
    }
  }
  
  func removeAllValues() throws {
    let query = makeQuery()
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw error(from: status)
    }
  }
  
  private func makeQuery() -> [String: Any] {
    var query: [String: Any] = [:]
    query[String(kSecClass)] = kSecClassGenericPassword
    query[String(kSecAttrService)] = "One Minute"
    return query
  }
  
  
  private func error(from status: OSStatus) -> StorageError {
    let message = Config.localizedText(for: "Unhandled Error: \(status)")
    return .unhandledError(message: message)
  }
}
