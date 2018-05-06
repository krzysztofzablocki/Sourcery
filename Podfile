# Uncomment this line to define a global platform for your project
platform :osx, '10.11'

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
target 'CodableContextTests' do
  project 'Templates/Templates.xcodeproj'
  meta
  test_pods
end

target 'Sourcery' do
  pod 'Stencil', '0.10.1'
  pod 'StencilSwiftKit', '2.4.0' 
  pod 'Commander', '0.6.0'
  pod 'PathKit', '0.8.0'
  pod "xcproj", '4.2.0'
  pod 'SourceKittenFramework', '0.20.0'
  pod 'SwiftTryCatch', :git => 'git@github.com:seanparsons/SwiftTryCatch', :commit => '798c512'
  pod 'libCommonCrypto'
  pod 'AEXML', '4.2.2'

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

swift4 = ['SourceKittenFramework', 'Yams', 'xcproj']

post_install do |installer|
  installer.pods_project.targets.each do |target|
    swift_version = '3.2'
    if swift4.include?(target.name)
      swift_version = '4.0'
    end
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = swift_version
    end
  end
end
