# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

target 'WechatLogin' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  pod 'AFNetworking'
  pod 'SVProgressHUD'
  pod 'WechatOpenSDK'

end

#解决每次pod install 之后 Swift Language Version报错
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end

