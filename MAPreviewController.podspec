#
# Be sure to run `pod lib lint MAPreviewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MAPreviewController'
  s.version          = '0.3.1'
  s.summary          = '图片视频查看器,支持视频和图片混合查看'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
图片视频查看器,支持视频和图片混合查看,单独的视频查看支持横屏,支持视频和图片长按保存
                       DESC

  s.homepage         = 'https://github.com/fengyunjue/MAPreviewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengyunjue' => 'ma772528138@qq.com' }
  s.source           = { :git => 'https://github.com/fengyunjue/MAPreviewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.static_framework = true

  s.source_files = 'MAPreviewController/Classes/**/*'
  
  s.resource_bundles = {
    'MAPreviewController' => ['MAPreviewController/Assets/*.png']
 }
  s.public_header_files = 'MAPreviewController/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit', 'AVFoundation'
    s.dependency 'MAAutoLayout'
    s.dependency 'SDWebImage'
    s.dependency 'SVProgressHUD'

end
