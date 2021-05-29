//
//  MemoryViewController.swift
//  TreasureChestSwiftDemo
//
//  Created by ming on 2020/5/18.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MemoryViewController: UIViewController {
    
    let textfield = UITextField()
    let textLabel = UILabel()
    let countLabel = UILabel()
    
    let leftBtn = UIButton()
    let rightBtn = UIButton()
    let appTutorialBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        view.addSubview(leftBtn)
        leftBtn.layer.borderWidth = 1
        leftBtn.frame = CGRect(x: 30, y: 80, width: 60, height: 30)
        leftBtn.setTitle("drive", for: .normal)
        leftBtn.setTitleColor(.red, for: .normal)
        
        view.addSubview(rightBtn)
        rightBtn.layer.borderWidth = 1
        rightBtn.frame = CGRect(x: 130, y: 80, width: 60, height: 30)
        rightBtn.setTitle("signal", for: .normal)
        rightBtn.setTitleColor(.red, for: .normal)
        
        view.addSubview(appTutorialBtn)
        appTutorialBtn.layer.borderWidth = 1
        appTutorialBtn.frame = CGRect(x: 230, y: 80, width: 60, height: 30)
        appTutorialBtn.setTitle("tutorial", for: .normal)
        appTutorialBtn.setTitleColor(.red, for: .normal)
        appTutorialBtn.rx.controlEvent(.touchUpInside).subscribe { (event) in
            
        }
        
        testView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch began")
        let showAlert: (String) -> Void = { str in print(str) }
        let signalEvent: Signal<Void> = rightBtn.rx.tap.asSignal()

        
        // ... 假设以下代码是在用户点击 button 后运行
        
        let newObserver: () -> Void = { showAlert("弹出提示框2") }
        signalEvent.emit(onNext: newObserver)
    }
    
    func testView() {
        textLabel.frame = CGRect(x: 40, y: 200, width: 100, height: 20)
        textLabel.textColor = .black
        textLabel.layer.borderWidth = 1
        view.addSubview(textLabel)
        
        countLabel.frame = CGRect(x: textLabel.right + 10, y: 200, width: 100, height: 20)
        countLabel.textColor = .red
        countLabel.layer.borderWidth = 1
        view.addSubview(countLabel)
            
        textfield.frame = CGRect(x: 40, y: textLabel.bottom + 30, width: 100, height: 40)
        view.addSubview(textfield)
        textfield.layer.borderWidth = 1
         
        
        testTextfieldRxSwift()
        testButtonRxDrive()
        testButtonRxSignal()
        testCreateRx()
    }
    
    func testTextfieldRxSwift() {
        let myDriver : Driver<String?> = textfield.rx.text.asDriver()
//        let observer = textLabel.rx.text
        myDriver.drive(textLabel.rx.text)
        myDriver.map{$0?.count.description}.drive(countLabel.rx.text)
    }
    
    func testButtonRxDrive() {
        let showAlert: (String) -> Void = { str in print(str) }
        let driveEvent: Driver<Void> = leftBtn.rx.tap.asDriver()
        
        let observer: () -> Void = { showAlert("弹出提示框1") }
        driveEvent.drive(onNext: observer)
        // ... 假设以下代码是在用户点击 button 后运行
        let newObserver: () -> Void = { showAlert("弹出提示框2") }
        driveEvent.drive(onNext: newObserver)
        
    }
    
    func testButtonRxSignal() {
//        let showAlert: (String) -> Void = { str in print(str) }
//        let signalEvent: Signal<Void> = rightBtn.rx.tap.asSignal()
////        let tmp:Observ
//        let observer: () -> Void = { showAlert("弹出提示框1") }
//        signalEvent.emit(onNext: observer)

        // ... 假设以下代码是在用户点击 button 后运行
        let tmp = rightBtn.rx.controlEvent(.touchUpInside)
        tmp.subscribe { (btn) in
            print(btn)
        }
        
    }
    
    func testCreateRx() {
        let numbers: Observable<Int> = Observable.create { observer -> Disposable in

            observer.onNext(0)
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onNext(4)
            observer.onNext(5)
            observer.onNext(6)
            observer.onNext(7)
            observer.onNext(8)
            observer.onNext(9)
            observer.onCompleted()

            return Disposables.create()
        }//.share()
        
        numbers.subscribe(onNext: { count in
            print(count)
            if count == 3 {
                numbers.subscribe(onNext: { count in print("sub \(count)")})
            }
                
            
        })
    }
    
}
