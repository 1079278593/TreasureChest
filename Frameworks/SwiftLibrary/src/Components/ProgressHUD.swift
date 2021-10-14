//
//  ProgressHUD.swift
//  MemoryKing
//
//  Created by ming on 2019/9/18.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import MBProgressHUD

public class ProgressHUD: NSObject {
    
    static let sharedInstance = ProgressHUD()
    var hud:MBProgressHUD!
    
    private override init() {
        super.init()
    }
    
    class func showWaiting(view: UIView?, isEnabled: Bool = true, text: String = "正在处理...") {
        ProgressHUD.sharedInstance.showWaiting(view: view, isEnabled: isEnabled, text: text)
    }
    
    class func hidden() {
        DispatchQueue.main.async {
            ProgressHUD.sharedInstance.hud.hide(animated: false)
        }
    }
    
    
}

public extension ProgressHUD {
    private func showWaiting(view: UIView?, isEnabled: Bool?, text: String) {
        
        guard let superView:UIView = view ?? UIApplication.shared.keyWindow else {
            return
        }
        
        if hud != nil {
            hud.removeFromSuperview()
            hud = nil
        }
        
        hud = MBProgressHUD.showAdded(to: superView, animated: true)
        hud.delegate = self
        hud.isUserInteractionEnabled = isEnabled ?? true
        
        //常用设置
        //小矩形的背景色
        hud.bezelView.color = UIColor.clear
        //显示的文字
        hud.label.text = text
        hud.label.numberOfLines = 0
        hud.label.lineBreakMode = .byCharWrapping
        //细节文字
        //        hud.detailsLabel.text = "请耐心等待..."
        //设置背景,加遮罩
        //        hud.backgroundView.style = .blur //或SolidColor
        //        hud.hide(animated: true, afterDelay: 2)
    }
    
    func showTip(view: UIView?, text: String, detail: String = "", delay: TimeInterval = 2) {
        guard let superView:UIView = view ?? UIApplication.shared.keyWindow else {
            return
        }
        
        hud = MBProgressHUD.showAdded(to: superView, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.label.text = text
        hud.label.numberOfLines = 0
        hud.label.lineBreakMode = .byCharWrapping
        hud.detailsLabel.text = detail
        hud.margin = 10
        hud.offset.y = 50
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: delay)
    }
    
    func showCustomTip(view: UIView?, text: String, delay: TimeInterval = 2) {
        guard let superView:UIView = view ?? UIApplication.shared.keyWindow else {
            return
        }
        
        hud = MBProgressHUD.showAdded(to: superView, animated: true)
        hud.mode = MBProgressHUDMode.customView
        hud.customView = UIImageView(image: UIImage(named: "pic_dui@2x"))
        hud.label.text = text
        hud.offset.y = -50
        hud.hide(animated: true, afterDelay: delay)
    }
}

extension ProgressHUD: MBProgressHUDDelegate {
    public func hudWasHidden(_ hud: MBProgressHUD) {
        print("hud was hidden")
    }
}
