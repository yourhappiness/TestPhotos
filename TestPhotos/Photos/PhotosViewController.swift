//
//  PhotosViewController.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 15.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit
import RxSwift

class PhotosViewController: UIViewController {
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  
  private var collectionView: UICollectionView?
  private let itemMargin: CGFloat = 20
  
  private let viewModel: ViewModel
  private var photoCellModels: [PhotoCellModel] = []
  
  // MARK: - Init
  init(viewModel: PhotosViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureUI()
    self.bindViewModel()
    self.viewModel.loadDataFromNetwork()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.viewModel.loadDataFromDatabase()
  }
  
  private func configureUI() {
    let collectionViewLayout = UICollectionViewFlowLayout()
    let itemWidth = (self.view.frame.width - self.itemMargin) / 2
    collectionViewLayout.estimatedItemSize = CGSize(width: itemWidth, height: itemWidth)
    collectionViewLayout.minimumInteritemSpacing = 1
    collectionViewLayout.minimumLineSpacing = 1
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = .gray
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.isUserInteractionEnabled = true
    self.view.addSubview(collectionView)
    self.collectionView = collectionView
    collectionView.delegate = self
    collectionView.dataSource = self
    
    collectionView.register(PhotoCollectionViewCell.self,
                                 forCellWithReuseIdentifier: PhotoCollectionViewCell.cellIdentifier)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
      collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }
  
  private func bindViewModel() {
    
    self.viewModel.error
        .asObservable()
        .observeOn(MainScheduler.asyncInstance)
        .subscribe { [weak self] event in
          switch event {
          case .next(let error):
            guard let error = error else {return}
            self?.showAlert(error: error)
          case .error(let error):
            self?.showAlert(error: error)
          case .completed:
            return
          }
    }
    .disposed(by: self.disposeBag)

    self.viewModel.cellModels
      .asObservable()
      .observeOn(MainScheduler.asyncInstance)
      .subscribe { [weak self] event in
      switch event {
      case .next(let cellModels):
        self?.photoCellModels = cellModels
        self?.collectionView?.reloadData()
      case .error(let error):
        self?.showAlert(error: error)
      case .completed:
        return
      }
    }
    .disposed(by: self.disposeBag)
  }
}

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  //MARK: - UICollectionViewDataSource
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.photoCellModels.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView?.dequeueReusableCell(
      withReuseIdentifier: PhotoCollectionViewCell.cellIdentifier,
      for: indexPath) as! PhotoCollectionViewCell
    let action = { self.didLongPressOnCell(at: indexPath) }
    cell.configure(with: self.photoCellModels[indexPath.item], action: action)
    return cell
  }

  //MARK: - UICollectionViewDelegate
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.viewModel.didTapOnPhoto(index: indexPath.item)
  }
  
  private func didLongPressOnCell(at indexPath: IndexPath){
    guard !(self.presentedViewController is UIAlertController) else {return}
    let message = "Вы действительно хотите удалить фотографию?\nОтмена действия невозможна"
    let alertVC = UIAlertController(title: "Удаление фото",
                                    message: message,
                                    preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Да", style: .destructive) { _ in
      self.viewModel.didLongPressOnPhoto(indexPath: indexPath)
    }
    let dismissAction = UIAlertAction(title: "Нет", style: .destructive)
    alertVC.addAction(deleteAction)
    alertVC.addAction(dismissAction)
    self.present(alertVC, animated: true, completion: nil)
  }
}

