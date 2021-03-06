//
//  PhotosViewModel.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import Kingfisher

protocol ViewModel {
  
  var cellModels: Variable<[PhotoCellModel]> {get set}
  var error: Variable<Error?> {get set}

  func loadDataFromNetwork()
  func loadDataFromDatabase()
  func didTapOnPhoto(index: Int)
  func didLongPressOnPhoto(indexPath: IndexPath)
  
}


/// ViewModel для отображения фото
public class PhotosViewModel: ViewModel {
  
  // MARK: - Observable properties
  internal var cellModels: Variable<[PhotoCellModel]> = Variable([])
  internal var error: Variable<Error?> = Variable(nil)
  internal var isLoading: Variable<Bool> = Variable(false)
  
  // MARK: - Properties
  weak var viewController: UIViewController?
  
  private let numberOfPhotosToBeLoaded: Int = 25
  private let pageToBeLoaded: Int = 1
  
  private var photos: [PhotoModel] = []

  private let networkService: NetworkServiceProtocol
  private let databaseService: DatabaseServiceProtocol
  
  // MARK: - Init
  init(networkService: NetworkServiceProtocol,
       databaseService: DatabaseServiceProtocol) {
    self.networkService = networkService
    self.databaseService = databaseService
  }
  
  // MARK: - ViewModel methods
  
  /// Загрузка данных из сети и сохранение их в БД
  public func loadDataFromNetwork() {
    let page: Int = self.pageToBeLoaded
    let limit: Int = self.numberOfPhotosToBeLoaded

    guard self.photos.count < self.numberOfPhotosToBeLoaded else {return}
    self.getEnoughData(page: page, limit: limit)
  }
  
  /// Загрузка данных из базы данных
  public func loadDataFromDatabase() {
    guard !self.isLoading.value else {return}
    guard let data = self.databaseService.loadData(type: PhotoModel.self, isDeleted: false) else {
      self.error.value = DatabaseError.loadDataError
      return
    }
    self.photos = Array(data)
    self.cellModels.value = self.viewModels()
  }
  
  /// Открытие детального экрана для просмотра фото
  /// - Parameter index: индекс необходимого фото в массиве
  public func didTapOnPhoto(index: Int) {
    let photoStringURL: String = self.photos[index].url
    guard let photoURL: URL = URL(string: photoStringURL) else {return}
    KingfisherManager.shared.retrieveImage(with: photoURL, options: nil, progressBlock: nil) { [weak self] response in
      switch response {
      case .success(let result):
        let image = result.image
        let detailedPhotoVC = DetailedPhotoViewController(image: image, nibName: nil, bundle: nil)
        detailedPhotoVC.view.backgroundColor = .black
        detailedPhotoVC.modalPresentationStyle = .overFullScreen
        self?.viewController?.present(detailedPhotoVC, animated: true, completion: nil)
        return
      case .failure(let error):
        self?.error.value = error
      }
    }
  }
  
  /// Обработка долгого нажатия на ячейку
  /// - Parameter indexPath: индекс нажатой ячейки
  public func didLongPressOnPhoto(indexPath: IndexPath) {
    let index = indexPath.item
    let photo = self.photos[index]
    let photoCopy: PhotoModel = self.copyPhoto(photo, isDeleted: true)
    self.databaseService.saveData([photoCopy], update: true)
    self.photos.remove(at: index)
    self.loadDataFromNetwork()
  }
  
  // MARK: - Private
  
  private func viewModels() -> [PhotoCellModel] {
    return self.photos.compactMap { photoModel -> PhotoCellModel in
      return PhotoCellModel(id: photoModel.id, photoURL: photoModel.url)
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
    self.isLoading.value = true
    self.loadData(page: page, limit: limit) { response in
      
      switch response {
        
      case .success(let photos):
        var acceptablePhotos: [PhotoModel] = self.photos
        var loadedPhotos: Set<PhotoModel> = Set(photos)
        
        DispatchQueue.main.async {
          if let deletedPhotosQuery = self.databaseService.loadData(type: PhotoModel.self,
                                                                    isDeleted: true) {
            let deletedPhotos: [PhotoModel] = Array(deletedPhotosQuery)
            loadedPhotos.subtract(deletedPhotos)
          }
    
          loadedPhotos.subtract(self.photos)
          
          DispatchQueue.global().async {
            guard loadedPhotos.count > 0 else {
              self.getEnoughData(page: page + 1, limit: limit)
              return
            }
            
            let loadedPhotosArray = Array(loadedPhotos).sorted {$0.id < $1.id}
            
            for photo in loadedPhotosArray {
              acceptablePhotos.append(photo)
              
              guard let index: Int = loadedPhotosArray.firstIndex(of: photo) else {
                self.error.value = UndefinedError.undefined
                return
              }
              
              if index == (loadedPhotosArray.count - 1) ||
                acceptablePhotos.count == self.numberOfPhotosToBeLoaded {
                DispatchQueue.main.async {
                  
                  self.photos = acceptablePhotos
                  self.databaseService.saveData(self.photos, update: true)
                  self.cellModels.value = self.viewModels()
                  
                  if self.cellModels.value.count < self.numberOfPhotosToBeLoaded {
                    self.getEnoughData(page: page + 1, limit: limit)
                  }
                  self.isLoading.value = false
                  
                }
                break
              }
            }
          }
        }
      case .failure(let error):
        self.error.value = error
        self.isLoading.value = false
        DispatchQueue.main.async {
          self.loadDataFromDatabase()
        }
      }
    }
  }
  
  private func copyPhoto(_ photo: PhotoModel, isDeleted: Bool) -> PhotoModel {
    let photoCopy = PhotoModel(id: photo.id,
                               author: photo.author,
                               width: photo.width,
                               height: photo.height,
                               url: photo.url)
    photoCopy.isDeleted = isDeleted
    return photoCopy
  }
  
}
