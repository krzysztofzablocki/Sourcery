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
  pod 'Stencil', '0.13.1'
  pod 'StencilSwiftKit', '2.7.0'
  pod 'Commander', '0.7.0'
  pod 'PathKit', '0.9.2'
  pod "xcproj", :git =>'git@github.com:tuist/xcodeproj.git', :tag => '4.3.1'
  pod 'SourceKittenFramework', '0.21.2'
  pod 'AEXML', '4.3.3'

  target 'SourceryTests' do
    inherit! :search_paths
    test_pods
  end
end

target 'SourceryJS' do
  pod 'PathKit', '0.9.2'
end

target 'SourcerySwift' do
  pod 'PathKit', '0.9.2'
end
