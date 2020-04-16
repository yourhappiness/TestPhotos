//
//  PhotoModel.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 15.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation
import RealmSwift

/// Модель фото для хранения в БД
public class PhotoModel: Object, Decodable {
  
  @objc
  public dynamic var id: String = ""
  @objc
  public dynamic var author: String = ""
  @objc
  public dynamic var width: Int = 0
  @objc
  public dynamic var height: Int = 0
  @objc
  public dynamic var url: String = ""
  @objc
  public dynamic var isDeleted: Bool = false
  
  
  override public static func primaryKey() -> String? {
    return "id"
  }
  
  public convenience init(id: String, author: String, width: Int, height: Int, url: String) {
    self.init()
    self.id = id
    self.author = author
    self.width = width
    self.height = height
    self.url = url
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case author
    case width
    case height
    case url = "download_url"
   }
  
}

extension PhotoModel {
  /// Сравнение двух объектов типа вместо реализации по умолчанию NSObject
  /// - Parameter object: объект для сравнения
  override public func isEqual(_ object: Any?) -> Bool {
    return self.id == (object as? PhotoModel)?.id
  }
}
