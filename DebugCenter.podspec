#
# Be sure to run `pod lib lint DebugCenter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DebugCenter'
  s.version          = '1.1.0'
  s.summary          = 'A short description of DebugCenter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/fenghanxu/DebugCenter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fenghanxu' => 'qq384170231@gmail.com' }
  s.source           = { :git => 'https://github.com/fenghanxu/DebugCenter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  # 头文件
#  s.public_header_files = ["Sources/**/*.h","Sources/*/**/*.h","Sources/*/*/**/*.h"]
  
  # 项目文件
  s.source_files = 'Sources/**/*.{swift,h,m,mm}'
  
  # 系统框架
  s.frameworks = 'UIKit', 'Foundation', 'PDFKit', 'AVKit', 'AVFoundation', 'QuickLook', 'ImageIO', 'MobileCoreServices', 'WebKit'
  
  # 内存管理模式
  s.requires_arc = true
  
  # 本地图片
   s.resource = 'Sources/file.bundle'
  
  # Swift语言支持的版本
  s.swift_versions = ['5.0']
  
end
