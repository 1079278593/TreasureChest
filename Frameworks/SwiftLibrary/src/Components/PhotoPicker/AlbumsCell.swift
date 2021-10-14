//
//  AlbumsCell.swift
//  MemoryKing
//
//  Created by ming on 2019/9/5.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public class AlbumsCell: UICollectionViewCell {
    
    let albumTitleLabel = UILabel()
    let coverView = UIImageView()
    private let breakLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        coverView.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        coverView.layer.masksToBounds = true
        coverView.contentMode = .scaleAspectFill
        self.contentView.addSubview(coverView)
        
        albumTitleLabel.textColor = .black
        albumTitleLabel.frame = CGRect(x: 60, y: 0, width: 400, height: 55)
        self.contentView.addSubview(albumTitleLabel)
        
        breakLine.backgroundColor = .lightGray
        breakLine.frame = CGRect(x: 20, y: 55, width: 400, height: 1)
        self.contentView.addSubview(breakLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
