#
# Be sure to run `pod lib lint WZRefresh.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WZRefresh'
  s.version          = '2.2.3'
  s.summary          = 'A short description of WZRefres'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about 

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/WZLYiOS/WZRefresh'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qiuqixiang' => '739140860@qq.com' }
  s.source           = { :git => 'https://github.com/WZLYiOS/WZRefresh.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.static_framework = true
  s.swift_version         = '5.0'
  s.requires_arc = true
  s.ios.deployment_target = '13.0'
  s.source_files = 'WZRefresh/Classes/*.swift'
  s.dependency 'MJRefresh', '~> 3.7.6'
end
