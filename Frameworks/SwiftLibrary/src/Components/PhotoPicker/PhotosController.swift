//
//  PhotosController.swift
//  MemoryKing
//
//  Created by ming on 2019/9/5.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import Photos

public protocol PhotosChoosedDelegate:class {
    func choosedPhoto(image: UIImage?)
}

public class PhotosController: UIViewController {
    
    private let KMainScreenWidth = UIScreen.main.bounds.width
    private let KMainScreenHeight = UIScreen.main.bounds.height
    private let KNaviAreaHeight: CGFloat = 44.0 + UIScreen.main.bounds.height >= 812 ? 44.0 : 20.0
    
    weak var delegate: PhotosChoosedDelegate?
    
    private let photosCellId = "photosCellId"
    private var collectionView: UICollectionView!
    private var photosAssets = [PHAsset]()
    private var selectedIndexs = [Int]()
    private var gifType = [Int]()
    private var album = PHAssetCollection()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        initSubViews()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showPhotosWith(album: PHAssetCollection) {
        self.album = album
        photosAssets = [PHAsset]()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        
        PHAsset.fetchAssets(in: album, options: options).enumerateObjects { (asset, index, stop) in
            self.photosAssets.append(asset)
        }
    }
}

extension PhotosController {
    private func initSubViews() {
        let padding:CGFloat = 2.0
        let width = (KMainScreenWidth-padding*2)/3.0
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        layout.itemSize = CGSize(width: width, height: width)
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.register(PhotosCell.self, forCellWithReuseIdentifier: photosCellId)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.frame = CGRect(x: 0, y: KNaviAreaHeight, width: KMainScreenWidth, height: KMainScreenHeight-KNaviAreaHeight)
        self.view.addSubview(collectionView)
    }
    
    private func getImageType() {
        for (index,asset) in photosAssets.enumerated() {
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            PHImageManager.default().requestImageData(for: asset, options: options) { (data, dataUTI, orientation, info) in
                if let _ = dataUTI?.components(separatedBy: ".").contains("gif") {
                    self.gifType.append(index)
                }
                print(self.gifType)
            }
            
        }
    }
}

extension PhotosController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosAssets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photosCellId, for: indexPath) as? PhotosCell else {
            return PhotosCell.init()
        }
        
        let asset = photosAssets[indexPath.row]
        
//        cell.selectedButton.tag = indexPath.row
//        cell.selectedButton.isSelected = selectedIndexs.contains(indexPath.row)
//        cell.selectedButton.addTarget(self, action: #selector(cellSelectedEvent(button:)), for: .touchUpInside)
        
//        cell.titleLabel.text = "\(asset.mediaType.rawValue)"
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        //        PHImageManager.default().requestImageData(for: asset, options: options) { (data, dataUTI, orientation, info) in
        //            print(dataUTI)
        //            if let imageData = data {
        //                cell.coverView.image = UIImage(data: imageData)
        //            }
        //
        //            cell.titleLabel.text = dataUTI
        //        }
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil) { (result, info) in
            cell.coverView.image = result
        }
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell else {
            return
        }
        
        self.delegate?.choosedPhoto(image: cell.coverView.image)
        self.navigationController?.popViewController(animated: false)
        
//        let photoShow = PhotoEditController()
//        photoShow.photoAsset = photosAssets[indexPath.row]
//        self.navigationController?.pushViewController(photoShow, animated: true)
    }
    
    @objc
    func cellSelectedEvent(button: UIButton) {
        self.selectedIndexs = self.selectedIndexs.filter{$0 != button.tag}
        if !button.isSelected {
            self.selectedIndexs.append(button.tag)
        }
        button.isSelected = !button.isSelected
    }
}
