//
//  VerticalLabel.swift
//  MemoryKing
//
//  Created by ming on 2019/9/15.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

enum VerticalAlignment {
    case top
    case middle
    case bottom
}

public class VerticalLabel: UILabel {

    var alignment = VerticalAlignment.middle {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch alignment {
        case .top:
            textRect.origin.y = bounds.origin.y
         case .bottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        case .middle:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height)
        }
        return textRect
    }
    
    public override func drawText(in rect: CGRect) {
        let actualRect = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: actualRect)
    }
}
