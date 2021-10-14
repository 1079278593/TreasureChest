//
//  AlbumsController.swift
//  MemoryKing
//
//  Created by ming on 2019/9/5.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import Photos

public protocol AlbumsDelegate:class {
    func photosCtlChoosedPhoto(image: UIImage?)
}

public class AlbumsController: UIViewController {
    
    weak var delegate: AlbumsDelegate?
    
    private let albumsCellId = "albumsCellId"
    private var albumsDatas = [PHAssetCollection]()
    private var collectionView:UICollectionView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        CheckAuthorization.checkAlbumAuthorizationStatus { (flag) in
            if flag {
                self.albumsDatas = PhotoPickerManager.sharedInstance.assetCollection
                self.initSubViews()
            } else {
                let hud = ProgressHUD.sharedInstance
                hud.showTip(view: nil, text: "无法获取照片，请到设置中开启权限", detail: "", delay: 2)
            }
        }
        
        
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AlbumsController {
    private func initSubViews() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.register(AlbumsCell.self, forCellWithReuseIdentifier: albumsCellId)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height - 64)
        self.view.addSubview(collectionView)
    }
    
    private func showPhotos(albumIndex: Int, animated: Bool) {
        let photosController = PhotosController()
        photosController.delegate = self
        photosController.showPhotosWith(album: self.albumsDatas[albumIndex])
        self.navigationController?.pushViewController(photosController, animated: animated)
    }
}

extension AlbumsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsDatas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: albumsCellId, for: indexPath) as? AlbumsCell else {
            return AlbumsCell.init();
        }

        let assetCollection = albumsDatas[indexPath.row]
        let count:Int = assetCollection.photosCount
        if let albumTitle = assetCollection.localizedTitle {
            cell.albumTitleLabel.text = String("\(albumTitle):\(count)")
        }
        
        
        if let asset = PHAsset.fetchAssets(in: assetCollection, options: nil).lastObject {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 60, height: 60), contentMode: .default, options: nil) { (result, _) in
                cell.coverView.image = result
            }
        }
        
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: 55)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showPhotos(albumIndex: indexPath.row, animated: true)
    }
}

extension AlbumsController: PhotosChoosedDelegate {
    public func choosedPhoto(image: UIImage?) {
        self.delegate?.photosCtlChoosedPhoto(image: image)
        self.navigationController?.popViewController(animated: true)
    }
}
