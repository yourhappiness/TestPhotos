//
//  PhotoCollectionViewCell.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {
  
  static let cellIdentifier = "PhotoCell"
  
  private var imageView: UIImageView?
  
  public var actionOnLongPress: (() -> Void)?
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.configureUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      self.configureUI()
  }
  
  // MARK: - Methods
  func configure(with cellModel: PhotoCellModel, action: (() -> Void)?) {
    self.imageView?.kf.indicatorType = .activity
    self.imageView?.kf.setImage(with: URL(string: cellModel.photoURL))
    self.actionOnLongPress = action
  }
  
  // MARK: - UI
  
  override func prepareForReuse() {
    self.imageView?.image = nil
  }
  
  private func configureUI() {
    self.addImageView()
  }
  
  private func addImageView() {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    self.contentView.addSubview(imageView)
    self.imageView = imageView
    
    NSLayoutConstraint.activate([
        imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
        imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
        imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
        imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
  }
  
}
