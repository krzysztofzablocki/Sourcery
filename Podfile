# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

workspace 'Sourcery.xcworkspace'
use_frameworks!
inhibit_all_warnings!

def meta
  pod 'SwiftLint'
end

def test_pods
  pod 'Quick'
  pod 'Nimble'
end

target 'TemplatesTests' do
  project 'Templates/Templates.xcodeproj'
  meta
  test_pods
end

target 'Sourcery' do
  pod 'StencilSwiftKit', :git=>'https://github.com/SwiftGen/StencilSwiftKit.git', :branch=>'master'
  pod 'Commander'
  pod 'PathKit'
  pod 'XcodeEdit', '~> 1.0'
  pod 'SourceKittenFramework', '~> 0.17'
  pod 'SwiftTryCatch', :git => 'git@github.com:seanparsons/SwiftTryCatch', :commit => '798c512'
  pod 'libCommonCrypto'

  target 'SourceryTests' do
    inherit! :search_paths
    test_pods
  end
end

target 'SourceryJS' do
  pod 'PathKit'
end

target 'SourcerySwift' do
  pod 'PathKit'
  pod 'libCommonCrypto'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
