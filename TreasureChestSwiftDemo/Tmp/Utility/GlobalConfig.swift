//
//  GlobalConfig.swift
//  MemoryKing
//
//  Created by ming on 2019/4/21.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

let KUMengKey = "5d8352f23fc195e7a000094f"
let KAPPID = "1203171283"
let KAPPURL = "http://itunes.apple.com/lookup?id=" + KAPPID
let KAPPSTOREURL = "itms-apps://itunes.apple.com/cn/app/id\(KAPPID)?mt=8"

//人物图片
let KALIYUNPIC = "https://oss-new.oss-cn-beijing.aliyuncs.com/"
let KALIYUNPICFREE = KALIYUNPIC + "numpeople/"
let KALIYUNPICCHARGE = KALIYUNPIC + "vippeople/"

//版本更新提示
let KVERSIONCHECK = KALIYUNPIC + "checkVersion/flagPic.jpg"

let KMainScreenSize = UIScreen.main.bounds.size
let KMainScreenWidth = UIScreen.main.bounds.width
let KMainScreenHeight = UIScreen.main.bounds.height

let isIphoneX = KMainScreenHeight >= 812 ? true : false
//let isIphoneXR =
let isIphoneInch_under4 = KMainScreenHeight <= 568

let KStatusBarHeight: CGFloat = isIphoneX ? 44.0 : 20.0
let KNaviBarHeight: CGFloat = 44.0
let KNaviAreaHeight: CGFloat = KNaviBarHeight + KStatusBarHeight

let KTabbarHeight:CGFloat = 49.0
let KTabbarSafeMargin:CGFloat = isIphoneX ? 34.0 : 0.0

let KRestHeihtDeductionTopAndBottom = KMainScreenHeight - KStatusBarHeight - KNaviBarHeight - KTabbarHeight - KTabbarSafeMargin

let KPokerCornerRadius: CGFloat = 8

//所谓Aspect Ratio，描述的是画面出现在屏幕上的样子。拿4:3来说，4指的是宽度，3指高度。
let KPokerWidth: CGFloat  = 56.5               //56.5mm
let KPokerHeight: CGFloat  = 86.5              //86.5mm
let KPokerAspectRatio: CGFloat = KPokerWidth/KPokerHeight

//文件存储位置路径
let KFilePathInDomains = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? "") + "/"
let KPathCoverInDomains = KFilePathInDomains + "PathCover" + "/"


//版本号
let KAPPVERSION:String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
//Build号
let KAPPBUILDVERSION:String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
