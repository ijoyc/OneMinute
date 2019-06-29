//
//  StorageError.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/13.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

public enum StorageError : Error {
  case string2DataConversionError
  case data2StringConversionError
  case unhandledError(message: String)
}

extension StorageError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .string2DataConversionError:
      return Config.localizedText(for: "String to Data conversion error").value
    case .data2StringConversionError:
      return Config.localizedText(for: "Data to String conversion error").value
    case .unhandledError(let message):
      return Config.localizedText(for: message).value
    }
  }
}
