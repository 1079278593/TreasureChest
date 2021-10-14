//
//  PHAssetCollection+Count.swift
//  MemoryKing
//
//  Created by ming on 2021/4/29.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

import UIKit
import Photos

extension PHAssetCollection {
    var photosCount: Int {
        return PHAsset.fetchAssets(in: self, options: nil).count
    }
}
