//
//  PhotoPickerManager.swift
//  MemoryKing
//
//  Created by ming on 2019/9/5.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import Photos

public class PhotoPickerManager: NSObject {
    static let sharedInstance = PhotoPickerManager()
    var assetCollection = [PHAssetCollection]()

    private override init() {
        super.init()
        assetCollection = self.queryCollections()
    }
    
    private func queryCollections() -> [PHAssetCollection] {
        var albums = enumerateAssetCollection(collectionType: .smartAlbum, subtype: .albumRegular)
        albums.append(contentsOf: enumerateAssetCollection(collectionType: .album, subtype: .smartAlbumUserLibrary))
        var resultAlbums = [PHAssetCollection]()
        for album in albums {
            if album.assetCollectionSubtype == .smartAlbumUserLibrary {
                resultAlbums.insert(album, at: 0)
                continue
            }
            resultAlbums.append(album)
        }
        return resultAlbums
    }
    
    private func enumerateAssetCollection(collectionType: PHAssetCollectionType, subtype: PHAssetCollectionSubtype) -> [PHAssetCollection] {
        
        var resultAlbums = [PHAssetCollection]()
        let fetchAlbums = PHAssetCollection.fetchAssetCollections(with: collectionType, subtype: subtype, options: nil)
        fetchAlbums.enumerateObjects { (collection, index, stop) in
            if collection.photosCount > 0 {
                resultAlbums.append(collection)
            }
        }
        return resultAlbums
    }
}
