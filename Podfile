# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

workspace 'Sourcery.xcworkspace'
use_frameworks!

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
  meta

  pod 'StencilSwiftKit', '~> 1.0'
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

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
