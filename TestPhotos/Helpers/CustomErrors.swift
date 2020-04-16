//
//  DatabaseError.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

/// Ошибка базы данных
enum DatabaseError: Error {
  case loadDataError
}

extension DatabaseError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .loadDataError:
      return "Ошибка в загрузке данных из базы"
    }
  }
}


/// Неопределенная ошибка
enum UndefinedError: Error {
  case undefined
}

extension UndefinedError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .undefined:
      return "Неизвестная ошибка"
    }
  }
}
