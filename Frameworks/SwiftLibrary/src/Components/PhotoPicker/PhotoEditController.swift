//
//  PhotoEditController.swift
//  MemoryKing
//
//  Created by ming on 2019/9/5.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

public class PhotoEditController: UIViewController {
    
    var photoAsset:PHAsset?
    private let scrollView = UIScrollView()
    private let photoView = UIImageView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubViews()
    }

    func showPhoto(image: UIImage, url: String? = nil) {
        if let url = URL(string: url ?? "") {
            ProgressHUD.showWaiting(view: nil, isEnabled: false, text: "拼命加载中...")
            self.photoView.kf.setImage(with: ImageResource(downloadURL: url), placeholder: image, options: nil, progressBlock: nil) { (img, error, cacheType, url) in
                ProgressHUD.hidden()
            }
        } else {
            self.photoView.image = image
        }
    }
    
    func showPhoto(asset: PHAsset) {
        self.photoAsset = asset
        if let asset = photoAsset {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 550, height: 550), contentMode: .aspectFill, options: nil) { (result, info) in
                self.photoView.image = result
            }
        }
    }
    
    @objc
    func tapGesture() {
        self.dismiss(animated: false, completion: nil)
    }
}

extension PhotoEditController {
    private func initSubViews() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2
        scrollView.frame = self.view.bounds
        self.view.addSubview(scrollView)
        
        photoView.isUserInteractionEnabled = true
        photoView.frame = self.view.bounds
        photoView.contentMode = .scaleAspectFit
        photoView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapGesture)))
        scrollView.addSubview(photoView)
    }
}

extension PhotoEditController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var frame = photoView.frame
        let widthRemaining = self.scrollView.frame.width - photoView.frame.width
        let heightRemaining = self.scrollView.frame.height - photoView.frame.height
        frame.origin.x = widthRemaining > 0 ? widthRemaining*0.5 : 0
        frame.origin.y = heightRemaining > 0 ? heightRemaining*0.5 : 0
        
        photoView.frame = frame
        self.scrollView.contentSize = CGSize(width: frame.width + 30, height: frame.height + 30)
    }
}
