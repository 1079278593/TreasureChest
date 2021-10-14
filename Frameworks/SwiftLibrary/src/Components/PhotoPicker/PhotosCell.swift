//
//  PhotosCell.swift
//  MemoryKing
//
//  Created by ming on 2019/9/5.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public class PhotosCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let coverView = UIImageView()
    let selectedButton = UIButton()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        coverView.frame = self.bounds
        coverView.layer.masksToBounds = true
        coverView.contentMode = .scaleAspectFill
        self.contentView.addSubview(coverView);coverView.backgroundColor = .gray
        
        titleLabel.textColor = .red
        titleLabel.frame = CGRect(x: 0, y: 70, width: 100, height: 30)
        self.contentView.addSubview(titleLabel)
        
        selectedButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        selectedButton.layer.cornerRadius = selectedButton.frame.width / 2.0
        selectedButton.layer.masksToBounds = true
        selectedButton.setBackgroundImage(UIImage(named: "check"), for: .normal)
        selectedButton.setBackgroundImage(UIImage(named: "check_h"), for: .selected)
        self.contentView.addSubview(selectedButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
