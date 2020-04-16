//
//  UserDefaultsService.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

/// Сервис для работы с UserDefaults
public class UserDefaultsService {
  
  private let userDefaults = UserDefaults.standard
  private let key: String = "deletedPhotos"
  
  /// Сохранение id  удаленного фото в UserDefaults
  /// - Parameter photoId: id фото
  public func save(photoId: String) {
    var deletedPhotosArray: [String]? = self.getDeletedPhotos()
    if deletedPhotosArray == nil {
      deletedPhotosArray = []
    }
    deletedPhotosArray?.append(photoId)
    self.userDefaults.set(deletedPhotosArray, forKey: self.key)
  }
  
  /// Получение массива данных из UserDefaults
  public func getDeletedPhotos() -> [String]? {
    return self.userDefaults.array(forKey: self.key) as? [String]
  }
  
}
