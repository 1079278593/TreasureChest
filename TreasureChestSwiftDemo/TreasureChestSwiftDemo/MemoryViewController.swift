//
//  MemoryViewController.swift
//  TreasureChestSwiftDemo
//
//  Created by ming on 2020/5/18.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import UIKit
import Lottie

class MemoryViewController: UIViewController {
    let leftBtn = UIButton()
    let rightBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(leftBtn)
        view.addSubview(rightBtn)
        leftBtn.frame = CGRect(x: 30, y: 80, width: 60, height: 30)
        rightBtn.frame = CGRect(x: 130, y: 80, width: 60, height: 30)
        leftBtn.layer.borderWidth = 1
        rightBtn.layer.borderWidth = 1
        leftBtn.addTarget(self, action: #selector(leftBtnEvent), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(rightBtnEvent), for: .touchUpInside)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //https://o.yinliqu.com/gift/dabai.json
        //https://o.yinliqu.com/gift/lihua2.json
    }
    
    @objc func leftBtnEvent() {
        let animationView = AnimationView(url: URL(string: "https://o.yinliqu.com/gift/dabai.json")!) { (err) in}
        animationView.layer.borderWidth = 1;
        animationView.frame = CGRect(x: 30, y: 150, width: 100, height: 100);
        view.addSubview(animationView)
        animationView.play { (isFinish) in
            
        }
    }
    
    @objc func rightBtnEvent() {
        let animationView = AnimationView(url: URL(string: "https://o.yinliqu.com/gift/lihua2.json")!) { (err) in}
        animationView.layer.borderWidth = 1;
        animationView.frame = CGRect(x: 130, y: 150, width: 100, height: 100);
        view.addSubview(animationView)
        animationView.play { (isFinish) in
            
        }
    }
}
