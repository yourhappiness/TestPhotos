//
//  DatabaseService.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation
import RealmSwift

protocol DatabaseServiceProtocol {
  
  func saveData <T: Object> (_ data: [T], update: Bool)
  
  func loadData <T: Object> (type: T.Type) -> Results<T>?
  
  func deleteData <T: Object> (_ data: [T])
  
}

/// Сервис для работы с базой данных
public class DatabaseService: DatabaseServiceProtocol {
  
  private let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
  private var realm: Realm?
  
  /// Инициализатор
  public init() {
    self.getRealm()
    print(self.realm?.configuration.fileURL as Any)
  }
  
  private func getRealm() {
    self.realm = try? Realm(configuration: self.configuration)
  }
  
  /// Сохраняет данные в базе данных
  ///
  /// - Parameter data: данные для сохранения
  public func saveData <T: Object> (_ data: [T], update: Bool = false) {
    DispatchQueue.main.async {
      let updatePolicy: Realm.UpdatePolicy
      if update {
        updatePolicy = .modified
      } else {
        updatePolicy = .error
      }
      try? self.realm?.write {
        self.realm?.add(data, update: updatePolicy)
      }
    }
  }
  
  /// Загружает данные из базы
  ///
  /// - Returns: результат запроса к базе
  public func loadData <T: Object> (type: T.Type) -> Results<T>? {
    return self.realm?.objects(type)
  }
  
  /// Удаляет данные из базы
  ///
  /// - Parameter data: данные для удаления
  public func deleteData <T: Object> (_ data: [T]) {
    DispatchQueue.main.async {
      try? self.realm?.write {
        self.realm?.delete(data)
      }
    }
  }
}
