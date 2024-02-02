//
//  MyRxTableView.swift
//  TreasureChestSwiftDemo
//
//  Created by ming on 2021/10/24.
//  Copyright © 2021 xiao ming. All rights reserved.
//

import Foundation
import RxSwift

class ViewController: UIViewController {
    var tableView = UITableView(frame: .zero)
    let kCellHeight: CGFloat = 40
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupSubviews()
    }
}

extension ViewController {
    func setupSubviews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.safeEdges(to: view)
        //1.创建可观察数据源
        let texts = ["Objective-C", "Swift", "RXSwift"]
        let textsObservable = Observable.from(texts)
        //2. 将数据源与 tableView 绑定
        textsObservable.bind(to: tableView.rx
            .items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, text, cell) in
                cell.textLabel?.text = "\(text)"
            }
            .disposed(by: disposeBag)
        //3. 绑定 tableView 的事件
        tableView.rx.itemSelected.bind { [weak self](indexPath) in
            print(indexPath)
        }
        .disposed(by: disposeBag)

        //4. 设置 tableView Delegate/DataSource 的代理方法
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
