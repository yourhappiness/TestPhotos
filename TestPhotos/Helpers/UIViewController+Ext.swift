//
//  UIViewController+Ext.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

//Показ модального окна с ошибкой
extension UIViewController {
    func showAlert(error: Error) {
      DispatchQueue.main.async {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
      }
    }
}
