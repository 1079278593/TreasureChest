//
//  NumKeyboardView.swift
//  MemoryKing
//
//  Created by ming on 2019/5/11.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public protocol NumKeyboardViewDelegate: NSObjectProtocol {
    func filterView(_ didSelectFilterNumbers: String)
}

public class NumKeyboardView: UIView {

    weak var delegae: NumKeyboardViewDelegate?
    private var filterButtons = [UIButton]()
    private var filterNumber = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NumKeyboardView {
    private func initSubViews() {
        
        let buttonHeight:CGFloat = 33
        let buttonWidth:CGFloat = 52
        let paddingWidth: CGFloat = (frame.width - buttonWidth*5)/4.0
        let paddingHeight: CGFloat = frame.height - buttonHeight*2
        let contentSize = CGSize(width: buttonWidth + paddingWidth, height: buttonHeight + paddingHeight)
        
        for index in 0..<10 {
            let button = setupFilterButton(index: index)
            let indexPath = NSIndexPath(row: index % 5, section: index / 5)
            button.frame = CGRect(x: CGFloat(indexPath.row) * contentSize.width,
                                  y: CGFloat(indexPath.section) * contentSize.height,
                                  width: buttonWidth,
                                  height: buttonHeight)
            button.layer.cornerRadius = buttonHeight/2.0
            self.addSubview(button)
            filterButtons.append(button)
        }
    }
    
    private func setupFilterButton(index: Int) -> UIButton {
        let button = UIButton()
        button.tag = index
        button.setTitle("\(index)", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setBackgroundImage(UIImage.image(withColor: UIColor.hexColor("c1deff")), for: .normal)
        button.setBackgroundImage(UIImage.image(withColor: UIColor.hexColor("fed542")), for: .selected)
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonEvent(button:)), for: .touchUpInside)
        return button
    }
}

extension NumKeyboardView {
    
    @objc
    func buttonEvent(button: UIButton) {
        if isDoubleNumber() {
            buttonSelectedCancel()
        }
        button.isSelected = true
        self.delegae?.filterView(componentSelectedNumber(button: button))
    }
    
    private func getSelectedCount() -> Int {
        var selectedCount = 0
        for button in filterButtons {
            if button.isSelected {
                selectedCount += 1
            }
        }
        return selectedCount
    }
    
    private func buttonSelectedCancel() {
        for button in filterButtons {
            button.isSelected = false
        }
    }
    
    private func componentSelectedNumber(button: UIButton) ->String {
        if isDoubleNumber() {
            filterNumber = "\(button.tag)"
        } else {
            filterNumber += "\(button.tag)"
        }
        return filterNumber
    }
    
    private func isDoubleNumber() -> Bool {
        return filterNumber.count == 2
    }
}
