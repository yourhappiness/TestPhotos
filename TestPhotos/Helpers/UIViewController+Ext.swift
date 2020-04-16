//
//  UIViewController+Ext.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

// MARK: - Показывает alertVC с нужным текстом
public extension UIViewController {
  func showAlert(title: String, message: String) {
    let alertVC = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)
    let okAction = UIAlertAction(title: "ОК", style: .destructive, handler: nil)
    alertVC.addAction(okAction)
    self.present(alertVC, animated: true, completion: nil)
  }
}
