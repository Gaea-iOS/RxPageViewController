#
# Be sure to run `pod lib lint RxPageViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxPageViewController'
  s.version          = '0.2.2'
  s.summary          = 'A short description of RxPageViewController.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wangxiaotao/RxPageViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wangxiaotao' => '445242970@qq.com' }
  s.source           = { :git => 'https://github.com/wangxiaotao/RxPageViewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.swift_version = '4.2'

  s.source_files = 'RxPageViewController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RxPageViewController' => ['RxPageViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'RxSwift', '~> 4.4'
  s.dependency 'RxCocoa', '~> 4.4'
  s.dependency 'RxSwiftExt', '~> 3.4'
  s.dependency 'RxReachability', '~> 0.1.7'
end
