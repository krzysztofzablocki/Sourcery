# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Sourcery' do
  use_frameworks!

  pod 'Stencil', '~> 0.8.0'
  pod 'StencilSwiftKit', '~> 1.0.0'
  pod 'Commander'
  pod 'PathKit'
  pod 'XcodeEdit', '~> 1.0'
  pod 'SourceKittenFramework', :git => "git@github.com:jpsim/SourceKitten", :commit => '380a5f6'
  pod 'SwiftTryCatch', :git => 'git@github.com:seanparsons/SwiftTryCatch', :commit => '798c512'
  pod 'libCommonCrypto'

  target 'SourceryTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
