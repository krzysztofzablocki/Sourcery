#!/usr/bin/rake
## Most of this code is adapted from Sourcery https://github.com/AliSoftware/Sourcery/blob/master/Rakefile

require 'pathname'
require 'yaml'
require 'json'
require 'net/http'
require 'uri'

BUILD_DIR = 'build/'

## [ Utils ] ##################################################################

def version_select
  # Find all Xcode 8 versions on this computer
  xcodes = `mdfind "kMDItemCFBundleIdentifier = 'com.apple.dt.Xcode' && kMDItemVersion = '8.*'"`.chomp.split("\n")
  if xcodes.empty?
    raise "\n[!!!] You need to have Xcode 8.x to compile Sourcery.\n\n"
  end
  # Order by version and get the latest one
  vers = lambda { |path| `mdls -name kMDItemVersion -raw "#{path}"` }
  latest_xcode_version = xcodes.sort { |p1, p2| vers.call(p1) <=> vers.call(p2) }.last
  %Q(DEVELOPER_DIR="#{latest_xcode_version}/Contents/Developer" TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault.xctoolchain)
end

def xcpretty(cmd)
  if `which xcpretty` && $?.success?
    sh "set -o pipefail && #{cmd} | xcpretty -c"
  else
    sh cmd
  end
end

def xcrun(cmd)
  xcpretty "#{version_select} xcrun #{cmd}"
end

def print_info(str)
  (red,clr) = (`tput colors`.chomp.to_i >= 8) ? %W(\e[33m \e[m) : ["", ""]
  puts red, "== #{str.chomp} ==", clr
end
## [ Tests & Clean ] ##########################################################

desc "Run the Unit Tests"
task :tests do
  print_info "Running Unit Tests"
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme Sourcery -sdk macosx test)
end

desc "Delete the build/ directory"
task :clean do
  sh %Q(rm -fr build)
end

task :build do
  print_info "Building project"
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme Sourcery-Release -sdk macosx -derivedDataPath #{BUILD_DIR}/tmp/)
  sh %Q(rm -fr bin/Sourcery.app)
  `mv #{BUILD_DIR}tmp/Build/Products/Release/Sourcery.app bin/`
  sh %Q(rm -fr #{BUILD_DIR}tmp/)
end

desc "Update docs"
task :docs do
  print_info "Updating docs"
  sh "jazzy --clean --skip-undocumented"
end

## [ Release ] ##########################################################

namespace :release do
  desc 'Create a new release on GitHub, CocoaPods and Homebrew'
  task :new => [:check_versions, :build, :tests, :github, :cocoapods]

  def podspec_version(file = 'Sourcery')
    JSON.parse(`bundle exec pod ipc spec #{file}.podspec`)["version"]
  end

  def log_result(result, label, error_msg)
    if result
      puts "#{label.ljust(25)} \u{2705}"
    else
      puts "#{label.ljust(25)} \u{274C}  - #{error_msg}"
    end
    result
  end

  desc 'Check if all versions from the podspecs and CHANGELOG match'
  task :check_versions do
    results = []

    # Check if bundler is installed first, as we'll need it for the cocoapods task (and we prefer to fail early)
    `which bundler`
    results << log_result( $?.success?, 'Bundler installed', 'Please install bundler using `gem install bundler` and run `bundle install` first.')

    # Extract version from Sourcery.podspec
    version = podspec_version
    puts "#{'Sourcery.podspec'.ljust(25)} \u{1F449}  #{version}"

    # Check if entry present in CHANGELOG
    changelog_entry = system(%Q{grep -q '^## #{Regexp.quote(version)}$' CHANGELOG.md})
    results << log_result(changelog_entry, "CHANGELOG, Entry added", "Please add an entry for #{version} in CHANGELOG.md")

    changelog_master = system(%q{grep -qi '^## Master' CHANGELOG.md})
    results << log_result(!changelog_master, "CHANGELOG, No master", 'Please remove entry for master in CHANGELOG')

    exit 1 unless results.all?

    print "Release version #{version} [Y/n]? "
    exit 2 unless (STDIN.gets.chomp == 'Y')
  end

  desc 'Create a zip containing all the prebuilt binaries'
  task :zip => [:clean, :docs] do
    sh %Q(mkdir -p "build")
    sh %Q(mkdir -p "build/Resources")
    sh %Q(cp -r bin build/)
    sh %Q(cp -r Templates build/)
    sh %Q(cp -r docs/docsets/Sourcery.docset build/)
    `cp LICENSE README.md CHANGELOG.md build`
    `cp Resources/daemon.gif Resources/icon-128.png build/Resources`
    `cd build; zip -r -X sourcery-#{podspec_version}.zip .`
  end

  def post(url, content_type)
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' => content_type})
    yield req if block_given?
    req.basic_auth 'krzysztofzablocki', File.read('.apitoken').chomp

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => (uri.scheme == 'https')) do |http|
      http.request(req)
    end
    unless response.code == '201'
      puts "Error: #{response.code} - #{response.message}"
      puts response.body
      exit 3
    end
    JSON.parse(response.body)
  end

  desc 'Upload the zipped binaries to a new GitHub release'
  task :github => :zip do
    v = podspec_version

    changelog = `sed -n /'^## #{v}$'/,/'^## '/p CHANGELOG.md`.gsub(/^## .*$/,'').strip
    print_info "Releasing version #{v} on GitHub"
    puts changelog

    json = post('https://api.github.com/repos/krzysztofzablocki/Sourcery/releases', 'application/json') do |req|
      req.body = { :tag_name => v, :name => v, :body => changelog, :draft => false, :prerelease => false }.to_json
    end

    upload_url = json['upload_url'].gsub(/\{.*\}/,"?name=Sourcery-#{v}.zip")
    zipfile = "build/Sourcery-#{v}.zip"
    zipsize = File.size(zipfile)

    print_info "Uploading ZIP (#{zipsize} bytes)"
    post(upload_url, 'application/zip') do |req|
      req.body_stream = File.open(zipfile, 'rb')
      req.add_field('Content-Length', zipsize)
      req.add_field('Content-Transfer-Encoding', 'binary')
    end
  end

  desc 'pod trunk push Sourcery to CocoaPods'
  task :cocoapods do
    print_info "Pushing pod to CocoaPods Trunk"
    sh 'bundle exec pod trunk push Sourcery.podspec --allow-warnings'
  end
end
