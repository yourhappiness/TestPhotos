//
//  PhotosViewModel.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation
//import RxSwift
import Alamofire

public class PhotosViewModel {
  
  // MARK: - Observable properties
  internal var cellModels: [PhotoCellModel] = []
  internal var error: Error?
  
  // MARK: - Properties
  weak var viewController: UIViewController?
  
  private let numberOfPhotosToBeLoaded: Int = 25
  private let pageToBeLoaded: Int = 1
  
  private var photos: [PhotoModel] = []
  private var deletedPhotos: [String] = []

  private let networkService: NetworkServiceProtocol
  private let databaseService: DatabaseServiceProtocol
  private let userDefaultsService: UserDefaultsService
  
  // MARK: - Init
  init(networkService: NetworkServiceProtocol,
       databaseService: DatabaseServiceProtocol,
       userDefaultsService: UserDefaultsService) {
    self.networkService = networkService
    self.databaseService = databaseService
    self.userDefaultsService = userDefaultsService
    self.loadDataFromNetwork()
  }
  
  // MARK: - ViewModel methods\
  
  public func loadDataFromNetwork() {
    let page: Int = self.pageToBeLoaded
    var photosCount: Int = self.numberOfPhotosToBeLoaded
    
    if self.photos.count > 0 {
      photosCount = self.numberOfPhotosToBeLoaded - self.photos.count
    }
    
    self.loadDeletedPhotos()
    self.getEnoughData(page: page, limit: photosCount)
  }
  
  /// Загрузка данных из базы данных
  public func loadDataFromDatabase() {
    guard let data = self.databaseService.loadData(type: PhotoModel.self) else {
      self.error = DatabaseError.loadDataError
      return
    }
    self.photos = Array(data)
  }
  
  // MARK: - Private
  private func viewModels() -> [PhotoCellModel] {
      return self.photos.compactMap { photoModel -> PhotoCellModel in
        return PhotoCellModel(photoURL: photoModel.url)
      }
  }
  
  private func loadData(page: Int,
                        limit: Int,
                        completion: @escaping ((Result<[PhotoModel], Error>) -> Void)) {
    let parameters: Parameters = [
      "page" : page,
      "limit" : limit
    ]
    self.networkService.loadData(type: [PhotoModel.self], parameters: parameters) { response in
      switch response {
      case .success(let data):
        completion(.success(data))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  private func getEnoughData(page: Int, limit: Int) {
    self.loadData(page: page, limit: limit) { response in
      
      switch response {
        
      case .success(let photos):
        var acceptablePhotos: [PhotoModel] = []
        
        DispatchQueue.global().async {
          
          for photo in photos {
            if self.deletedPhotos.count > 0 {
              for deletedPhotoId in self.deletedPhotos {
                if photo.id != deletedPhotoId {
                  acceptablePhotos.append(photo)
                }
              }
            } else {
              acceptablePhotos.append(photo)
            }
            
            guard let index: Int = photos.firstIndex(of: photo) else {
              self.error = UndefinedError.undefined
              return
            }
            
            guard index != (photos.count - 1) || acceptablePhotos.count != self.numberOfPhotosToBeLoaded else {
              self.photos = acceptablePhotos
              
              DispatchQueue.main.async {
                self.databaseService.saveData(self.photos, update: true)
              }
              
              self.cellModels = self.viewModels()
              
              if self.cellModels.count < self.numberOfPhotosToBeLoaded {
                self.getEnoughData(page: page + 1, limit: limit)
              }
              return
            }
          }
          
        }
        
      case .failure(let error):
        self.error = error
      }
    }
  }
  
  private func loadDeletedPhotos() {
    guard let deletedPhotos = self.userDefaultsService.getDeletedPhotos() else {
      self.error = UserDefaultsError.loadDataError
      return
    }
    self.deletedPhotos = deletedPhotos
  }
}
