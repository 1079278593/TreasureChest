//
//  MKNetWorking.swift
//  MemoryKing
//
//  Created by ming on 2019/10/27.
//  Copyright © 2019 雏虎科技. All rights reserved.
//  https://www.jianshu.com/p/4381fe8e10b6

import UIKit
import HandyJSON
import Alamofire

enum RequestType {
    case Get
    
    case Post
    
    case Put
    
    case Delete
}

//typealias Complete = (Bool?, AnyObject?) -> Void
typealias SuccessBlock = ([String:Any]) -> Void
typealias FailureBlock = (AnyObject) -> Void
typealias ProgressBlock = (Float) -> Void

class MKNetWorking: NSObject {
    
    //MARK: - GET请求
    class func GET(url:String,param:[String:Any]?,success: @escaping SuccessBlock) {
        if param != nil {
            print("\n param:")
            print(param! as [String:Any])
        }
        print("url===:" + url)
        let urlPath:URL = URL(string: url)!
        let headers:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let request = AF.request(urlPath,method: .get,parameters: param,encoding: JSONEncoding.default, headers: headers)
        request.responseJSON { (response) in
            DispatchQueue.global().async(execute: {
                print(response.result)
                switch response.result {
                case let .success(result):
                    do {
                        let resultDict:[String:Any] = result as! [String:Any]
                        DispatchQueue.main.async(execute: {
                            /** 返回码处理 */
                            let resp_code: Int = (resultDict["resp_code"] as! Int)
                            switch resp_code {
                            case 0:
                                success(resultDict)
                            case 1: break
                                // SVProgressHUD.showError(withStatus: (resultDict["resp_msg"] as! String))
                            default: break
                                // SVProgressHUD.showError(withStatus: (resultDict["resp_msg"] as! String))
                            }
                        })
                    }
                case let .failure(error):
                    print(error)
                }

            })
        }
    }
    
    //MARK: - POST请求  字典参数 ["id":"1","value":""]
    class func POST(url:String,param:[String:Any]?,success: @escaping SuccessBlock) {
        if param != nil {
            print("\n param:")
            print(param! as [String:Any])
        }
        print("url===:" + url)
        if url.count == 0 {
            print("网络请求连接不正确")
            return;
        }
        let urlPath:URL = URL(string: url)!
        let headers:HTTPHeaders = ["Content-Type":"application/json;charset=UTF-8"]
        let request = AF.request(urlPath,method: .post,parameters: param,encoding: JSONEncoding.default, headers: headers)
        request.responseJSON { (response) in
            DispatchQueue.global().async(execute: {
                print(response.result)
                switch response.result {
                case let .success(result):
                    do {
                        let resultDict:[String:Any] = result as! [String:Any]
                        DispatchQueue.main.async(execute: {
                            /** 返回码处理 */
                            let resp_code: Int = (resultDict["resp_code"] as! Int)
                            switch resp_code {
                            case 0:
                                success(resultDict)
                            case 1: break
                                // SVProgressHUD.showError(withStatus: (resultDict["resp_msg"] as! String))
                            default: break
                                // SVProgressHUD.showError(withStatus: (resultDict["resp_msg"] as! String))
                            }
                        })
                    }
                case let .failure(error):
                    print(error)
                }

            })

        }
    }
    
    //MARK: - POST请求 数组参数（由于有数组参数的需求 ）[["id":"1","value":""],["id":"2","value":""]]
    class func POST2(url:String,param:Array<[String:String]>,success: @escaping SuccessBlock) {
        print("url===:" + url)
        let urlPath:URL = URL(string: url)!
        print("\n param:")
        let data = try? JSONSerialization.data(withJSONObject: param, options: [])
        var urlRequest = URLRequest(url: urlPath)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        urlRequest.allHTTPHeaderFields = ["application/json":"Accept","application/json;charset=UTF-8":"Content-Type"]

        let request = AF.request(urlRequest)
        request.responseJSON { (response) in
            DispatchQueue.global().async(execute: {
                print(response.result)
                switch response.result {
                case let .success(result):
                    do {
                        let resultDict:[String:Any] = result as! [String:Any]
                        DispatchQueue.main.async(execute: {
                            /** 返回码 (Int 类型code 会报崩) */
                            let code = resultDict["resp_code"]
                            var resp_code = 0
                            if code is String {
                                resp_code = Int(code as! String)!
                            } else if code is Int {
                                resp_code = code as! Int
                            }
                            switch resp_code {
                            case 0:
                                success(resultDict)
                            case 1: break
                                // SVProgressHUD.showError(withStatus: (resultDict["resp_msg"] as! String))
                            default: break
                                //SVProgressHUD.showError(withStatus: (resultDict["resp_msg"] as! String))
                            }
                        })
                    }
                case let .failure(error):
                    print(error)
                }

            })

        }
    }
    
}
