//
//  PhotoModel.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 15.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation
import RealmSwift

public class PhotoModel: Object {
  
  @objc
  private dynamic var id: String = ""
  @objc
  private dynamic var author: String = ""
  @objc
  private dynamic var width: Int = 0
  @objc
  private dynamic var height: Int = 0
  @objc
  private dynamic var url: String = ""
  
  
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
  
}
