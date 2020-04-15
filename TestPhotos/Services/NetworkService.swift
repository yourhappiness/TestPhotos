//
//  NetworkService.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 15.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol {
  
  func loadData<T : Decodable>(parameters: Parameters,
                               completion: @escaping (Result<T, Error>) -> Void)
    
}

/// Сервис для работы с сетью
public class NetworkService: NetworkServiceProtocol {
  
  private let baseURL: String
  
  init(url: String) {
    self.baseURL = url
  }
  
  /// Загрузка фотографий
  /// - Parameters:
  ///   - page: номер страницы, по умолчанию 1
  ///   - limit: количество фотографий, по умолчанию 25
  ///   - completion: результат запроса
  public func loadData<T : Decodable>(parameters: Parameters,
                                      completion: @escaping (Result<T, Error>) -> Void) {
    
    AF.request(baseURL, method: .get, parameters: parameters)
      .validate()
      .responseData(queue: DispatchQueue.global()) { response in
      switch response.result {
      case .success(let data):
        do {
          let result = try JSONDecoder().decode(T.self, from: data)
          completion(.success(result))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
}
