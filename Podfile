# Uncomment the next line to define a global platform for your project
use_frameworks!
platform :ios, '13.0'
inhibit_all_warnings!
#source 'https://github.com/CocoaPods/Specs.git'

workspace ‘TreasureChest.xcworkspace’
#project ‘TreasureChestSwiftDemo/TreasureChestSwiftDemo.xcodeproj’
#一个点就是上层目录，两个点就是上两层目录。
#参考林永坚课程：  project './Moments/Moments.xcodeproj'
#project '../Moments/Moments.xcodeproj'

abstract_target 'abstract_pod' do
  
  #----------TreasureChest----------#
  target 'TreasureChest' do
    project 'TreasureChestDemo/TreasureChest.xcodeproj’

    pod 'FMDB'
    pod 'Masonry'
    pod 'SDWebImage'
    pod 'AFNetworking'
    pod 'MJExtension'
    pod 'ReactiveObjC', '3.1.0'
    pod 'MSWeakTimer'
    pod 'MJRefresh', '3.2.0'
    pod 'SDAutoLayout', '~> 2.1.3'
    pod 'OCBaseLibrary', :path => './Frameworks/OCBaseLibrary', :inhibit_warnings => false
#    pod 'OAStackView'

    pod 'CocoaLumberjack'
    pod 'CocoaAsyncSocket'
    pod "GCDWebServer", "~> 3.0"
    pod 'RealReachability/Ping'
    
#    pod 'LibTorch', '~>1.6.0'
    
    target 'TreasureChestTests' do
      inherit! :search_paths
    end

  end




  #----------TreasureChestSwiftDemo----------#
  target 'TreasureChestSwiftDemo' do
    project 'TreasureChestSwiftDemo/TreasureChestSwiftDemo.xcodeproj’

    pod 'lottie-ios'
    pod 'SnapKit'
    pod 'HandyJSON'
    pod 'MBProgressHUD'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'Alamofire'
    pod 'MSWeakTimer'
    pod 'Kingfisher'
    pod 'FMDB'
    
    target 'TreasureChestSwiftDemoTests' do
      inherit! :search_paths
    end

  end
  
  
end

#规定target最小为iOS11
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
       end
    end
  end
end
