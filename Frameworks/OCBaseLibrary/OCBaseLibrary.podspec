# Start from https://github.com/CocoaPods/pod-template/blob/master/NAME.podspec
#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
# 参考：https://segmentfault.com/a/1190000012269307

Pod::Spec.new do |s|
  s.name             = 'OCBaseLibrary'
  s.version          = '1.0.0'
  s.summary          = 'All library or extentison'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Contains all library or extentison.
                       DESC

  s.homepage         = 'https://github.com/等待修改/treasure'
  s.license          = 'MIT'
  s.author           = 'MIT'
  s.source           = { :path => '.' }

  s.ios.deployment_target = '13.0'
  s.swift_versions = '5.3'

  s.source_files = 'src/**/*'
  
  # resources：配置资源文件（.bundle，.png，.txt等资源文件，这些资源文件会被放到mainBundle中，要注意避免发生命名重复的问题）
  # s.resources = 'assets/**/*'
  # s.resources = 'Resources/MyRes.bundle'

  # dependency：依赖的三方库，pod库或者可以是自身的subspec
  # s.dependency 'AFNetworking'   # 或者：s.dependency 'AFNetworking', '~>3.1.0'
  
  # 依赖的系统框架
  #s.frameworks = 'AVFoundation', 'CoreGraphics'
  
  # 依赖的非系统框架 ：这个依赖于本地是否有下载了相关的库       (frameworks文件夹和库源码文件夹'即Classes和Assets上层文件夹')
  # 如：s.vendored_frameworks = 'Frameworks/MyFramework.framework', 'frameworks/SnapKit.framework'
#  s.vendored_frameworks =
  
  # vendored_libraries：配置需要引用的非系统静态库
  # s.vendored_libraries = 'Frameworks/libZCPKit.a'
  
  # libraries：配置依赖的系统库（要注意，这里的写法需要忽略lib前缀）
  # s.libraries = 'c++', 'sqlite3', 'stdc++.6.0.9', 'z'
  
end
