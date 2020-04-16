//
//  DetailedPhotoViewController.swift
//  TestPhotos
//
//  Created by Anastasia Romanova on 16.04.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class DetailedPhotoViewController: UIViewController {
  
  private var image: UIImage
  private var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
  
  //MARK: - UIView properties
  private var photoView: UIImageView?

  private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
  private var pinchGestureRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer()
  
  //MARK: - Init
  init(image: UIImage, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.image = image
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - UI
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureUI()
  }
  
  private func configureUI() {
    self.configureImageView()
    self.configureGestureRecognizers()
  }
  
  private func configureImageView() {
    let imageView = UIImageView(image: self.image)
    imageView.isUserInteractionEnabled = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    self.view.addSubview(imageView)
    self.photoView = imageView
    
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)])
  }
  
  private func configureGestureRecognizers() {
    let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(closeDetailedView(_:)))
    self.view.addGestureRecognizer(panGestureRecognizer)
    self.panGestureRecognizer = panGestureRecognizer
    
    let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self,
                                                          action: #selector(scaleImage(_:)))
    self.photoView?.addGestureRecognizer(pinchGestureRecognizer)
    self.pinchGestureRecognizer = pinchGestureRecognizer
  }
  
  @objc
  private func scaleImage(_ sender: UIPinchGestureRecognizer) {
    sender.view?.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
    sender.scale = 1.0
  }
  
  @objc
  private func closeDetailedView(_ sender: UIPanGestureRecognizer) {
    let touchPoint = sender.location(in: self.view?.window)
    
    if sender.state == .began {
      self.initialTouchPoint = touchPoint
    } else if sender.state == .changed {
      if touchPoint.y - self.initialTouchPoint.y > 0 {
      self.view.frame = CGRect(x: 0,
                               y: touchPoint.y - self.initialTouchPoint.y,
                               width: self.view.frame.size.width,
                               height: self.view.frame.size.height)
      }
    } else if sender.state == .ended || sender.state == .cancelled {
      if touchPoint.y - self.initialTouchPoint.y > 100 {
          self.dismiss(animated: true, completion: nil)
      } else {
        UIView.animate(withDuration: 0.3, animations: {
          self.view.frame = CGRect(x: 0,
                                   y: 0,
                                   width: self.view.frame.size.width,
                                   height: self.view.frame.size.height)
        })
      }
    }
  }
}
