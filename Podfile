# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Insanity' do
  use_frameworks!

  pod 'Stencil'
  pod 'Commander'
  pod 'PathKit', :git => "git@github.com:kylef/PathKit.git", :commit => 'c662c2a'
  pod 'KZFileWatchers'
  pod 'SourceKitten', :git => "https://github.com/jpsim/SourceKitten", :commit => '9adc3e0'
  pod 'SwiftTryCatch', :git => 'https://github.com/seanparsons/SwiftTryCatch', :commit => '798c512'

  target 'InsanityTests' do
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
