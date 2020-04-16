//
//  Builder.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

/// Выполняет функцию первичной настройки модулей приложения
public class Builder {
  
  /// Первичная настройка модулей приложения
  public func build() -> UIViewController {
    let url = "https://picsum.photos/v2/list"
    let networkService = NetworkService(url: url)
    let databaseService = DatabaseService()
    let viewModel = PhotosViewModel(networkService: networkService,
                                    databaseService: databaseService)
    let rootVC = PhotosViewController(viewModel: viewModel)
    viewModel.viewController = rootVC
    return rootVC
  }
  
}
