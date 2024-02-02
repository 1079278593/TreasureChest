#  编译错误

一、https://www.jianshu.com/p/86a5313ce4cc
xcode 14.3

报错如下
Error (Xcode): File not found: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc/libarclite_iphonesimulator.a
方案：修改对应pod包，将最低版本改为 iOS 11.0
缺点：每次pod install这些命令就会被覆盖。

下面这个👇🏻：
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
       end
    end
  end
end
