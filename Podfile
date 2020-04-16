# Uncomment the next line to define a global platform for your project
use_frameworks!
platform :ios, '10.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

workspace ‘TreasureChest.xcworkspace’
#project ‘TreasureChestSwiftDemo/TreasureChestSwiftDemo.xcodeproj’

abstract_target 'abstract_pod' do
  
  #----------TreasureChest----------#
  target 'TreasureChest' do
    project ‘TreasureChestDemo/TreasureChest.xcodeproj’

    pod 'FMDB'
    pod 'Masonry'
    pod 'SDWebImage', '~> 3.7.5'
    pod 'AFNetworking'
    pod 'MJExtension'
    pod 'ReactiveObjC', '3.1.0'
    pod 'MSWeakTimer', '~> 1.1.0'
    pod 'MJRefresh', '3.2.0'
    
    target 'TreasureChestTests' do
      inherit! :search_paths
    end

  end




  #----------TreasureChestSwiftDemo----------#
  target 'TreasureChestSwiftDemo' do
    project ‘TreasureChestSwiftDemo/TreasureChestSwiftDemo.xcodeproj’

  #  pod 'FMDB'
  #  pod 'Masonry'
  #  pod 'SDWebImage', '~> 3.7.5'
  #  pod 'AFNetworking'
  #  pod 'MJExtension'
  #  pod 'ReactiveObjC', '3.1.0'
  #  pod 'MSWeakTimer', '~> 1.1.0'
  #  pod 'MJRefresh', '3.2.0'
    pod 'lottie-ios'
    
    target 'TreasureChestSwiftDemoTests' do
      inherit! :search_paths
    end

  end
  
  
end


