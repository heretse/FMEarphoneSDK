#
# Be sure to run `pod lib lint FMEarphoneSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FMEarphoneSDK'
  s.version          = '0.1.1'
  s.summary          = 'This a framework library to control FM functions with the Blackloud earbuds.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'FmEarphoneSDK is an iOS cocoapod library for controling the FM chip - Si4705 via EAP.'

  s.homepage         = 'https://github.com/heretse/FMEarphoneSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'heretse@gmail.com' => 'winston_hsieh@gemteks.com' }
  s.source           = { :git => 'https://github.com/heretse/FMEarphoneSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'FMEarphoneSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FMEarphoneSDK' => ['FMEarphoneSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
