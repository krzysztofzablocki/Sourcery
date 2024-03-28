Pod::Spec.new do |s|

  s.name         = "Sourcery"
  s.version      = "2.1.8"
  s.summary      = "A tool that brings meta-programming to Swift, allowing you to code generate Swift code."
  s.ios.deployment_target = '12'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '12'
  s.watchos.deployment_target = '4'

  s.description  = <<-DESC
                 A tool that brings meta-programming to Swift, allowing you to code generate Swift code.
                   * Featuring daemon mode that allows you to write templates side-by-side with generated code.
                   * Using SourceKit so you can scan your regular code.
                   DESC

  s.homepage     = "https://github.com/krzysztofzablocki/Sourcery"
  s.license      = 'MIT'
  s.author       = { "Krzysztof Zabłocki" => "krzysztof.zablocki@pixle.pl" }
  s.social_media_url = "https://twitter.com/merowing_"

  s.source       = { :http => "https://github.com/krzysztofzablocki/Sourcery/releases/download/#{s.version}/sourcery-#{s.version}.zip" }
  s.preserve_paths = '*'
  s.exclude_files = '**/file.zip'

  s.subspec 'CLI-Only' do |subspec|
    subspec.preserve_paths = "bin"
  end
end
