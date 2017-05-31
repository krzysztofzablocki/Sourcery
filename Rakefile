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
  # # Find all Xcode 8 versions on this computer
  # xcodes = `mdfind "kMDItemCFBundleIdentifier = 'com.apple.dt.Xcode' && kMDItemVersion = '8.*'"`.chomp.split("\n")
  # if xcodes.empty?
  #   raise "\n[!!!] You need to have Xcode 8.x to compile Sourcery.\n\n"
  # end
  # # Order by version and get the latest one
  # vers = lambda { |path| `mdls -name kMDItemVersion -raw "#{path}"` }
  # latest_xcode_version = xcodes.sort { |p1, p2| vers.call(p1) <=> vers.call(p2) }.last
  # %Q(DEVELOPER_DIR="#{latest_xcode_version}/Contents/Developer" TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault.xctoolchain)
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

## [ Bundler & CocoaPods ] ####################################################

desc "Install dependencies"
task :install_dependencies do
  sh %Q(bundle install)
  sh %Q(bundle exec pod install)
end

## [ Tests & Clean ] ##########################################################

desc "Run the Unit Tests on Templates project"
task test_templates: [:build] do
  print_info "Running Sourcery Templates Tests"
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme TemplatesTests -sdk macosx test)
end

desc "Run the Unit Tests on Sourcery project"
task :test_sourcery do
  print_info "Running Sourcery Unit Tests"
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme Sourcery -sdk macosx test)
end

desc "Run the Unit Tests on all projects"
task tests: [:test_sourcery, :test_templates]

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

## [ Docs ] ##########################################################

desc "Update docs"
task :docs do
  print_info "Updating docs"
  sh "sourcekitten doc --module-name SourceryRuntime > docs.json && bundle exec jazzy --clean --skip-undocumented && rm docs.json"
end

desc "Validate docs"
task :validate_docs do
  print_info "Checking docs are up to date"
  sh "sourcekitten doc --module-name SourceryRuntime > docs.json && bundle exec jazzy --skip-undocumented --no-download-badge && rm docs.json"
end

## [ Release ] ##########################################################

namespace :release do
  desc 'Create a new release on GitHub, CocoaPods and Homebrew'
  task :new => [:install_dependencies, :check_docs, :check_ci, :build, :tests, :update_metadata, :check_versions, :github, :cocoapods]

  def podspec_update_version(version, file = 'Sourcery.podspec')
    # The token is mainly taken from https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/helper/podspec_helper.rb
    podspec_content = File.read(file)
    version_var_name = 'version'
    version_regex = /^(?<begin>[^#]*version\s*=\s*['"])(?<value>(?<major>[0-9]+)(\.(?<minor>[0-9]+))?(\.(?<patch>[0-9]+))?)(?<end>['"])/i
    version_match = version_regex.match(podspec_content)
    updated_podspec_content = podspec_content.gsub(version_regex, "#{version_match[:begin]}#{version}#{version_match[:end]}")
    File.open(file, "w") { |f| f.puts updated_podspec_content }
  end

  def podspec_version(file = 'Sourcery')
    JSON.parse(`bundle exec pod ipc spec #{file}.podspec`)["version"]
  end

  def project_update_version(version, project = 'Sourcery')
    `sed -i '' -e 's/CURRENT_PROJECT_VERSION = #{project_version(project)};/CURRENT_PROJECT_VERSION = #{version};/g' #{project}.xcodeproj/project.pbxproj`
  end

  def project_version(project = 'Sourcery')
    `xcodebuild -showBuildSettings -project #{project}.xcodeproj | grep CURRENT_PROJECT_VERSION | sed -E  's/(.*) = (.*)/\\2/'`.strip
  end

  def log_result(result, label, error_msg)
    if result
      puts "#{label.ljust(25)} \u{2705}"
    else
      puts "#{label.ljust(25)} \u{274C}  - #{error_msg}"
    end
    result
  end

  def get(url, content_type = 'application/json')
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri, initheader = {'Content-Type' => content_type})
    yield req if block_given?

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => (uri.scheme == 'https')) do |http|
      http.request(req)
    end
    unless response.code == '200'
      puts "Error: #{response.code} - #{response.message}"
      puts response.body
      exit 3
    end
    JSON.parse(response.body)
  end

  def post(url, content_type = 'application/json')
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' => content_type})
    yield req if block_given?

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

  def manual_commit(files, message)
    commit_changes = STDIN.gets.chomp == 'Y'
    if commit_changes then
      system(%Q{git add #{files.join(" ")}})
      system(%Q{git commit -m '#{message}'})
    else
      system(%Q{git checkout #{files.join(" ")}})
      exit 2
    end
  end

  desc 'Check if CI is green'
  task :check_ci do
    print_info "Checking Circle CI master branch status"
    results = []

    json = get('https://circleci.com/api/v1.1/project/github/krzysztofzablocki/Sourcery/tree/master')
    master_branch_status = json[0]['status']
    results << log_result(master_branch_status == 'success', 'Master branch is green on CI', 'Please check master branch CI status first')
    exit 1 unless results.all?
  end

  desc 'Check if docs are up to date'
  task :check_docs => [:validate_docs] do
    results = []

    docs_not_changed = `git diff --name-only` == ""
    results << log_result(docs_not_changed, 'Docs are up to date', 'Please push updated docs first')
    exit 1 unless results.all?
  end

  desc 'Check if all versions from the podspecs, CHANGELOG and build settings match'
  task :check_versions do
    print_info "Checking versions match"
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

    # Check if Current Project Version from build settings match podspec version
    results << log_result(version == project_version, "Project version correct", "Please update Current Project Version in Build Settings to #{version}")

    exit 1 unless results.all?

    print "Release version #{version} [Y/n]? "
    exit 2 unless (STDIN.gets.chomp == 'Y')
  end

  desc 'Updates metadata for the new release'
  task :update_metadata do
    print "New version of Sourcery in sematic format [x.y.z]? "
    new_version = STDIN.gets.chomp
    unless new_version =~ /^\d+\.\d+\.\d+$/ then
      print "Please set version following the semantic format http://semver.org/\n"
      exit 3
    end

    print_info "Updating metadata for #{new_version} release\n"

    # Replace master with the new release version in CHANGELOG.md
    system(%Q{sed -i '' -e 's/## Master/## #{new_version}/' CHANGELOG.md})

    # Update podspec version
    podspec_update_version(new_version)

    # Update project version
    project_update_version(new_version)

    print "Now review and type [Y/n] to commit or cancel the changes. "
    manual_commit(["CHANGELOG.md", "Sourcery.podspec", "Sourcery.xcodeproj/project.pbxproj"], "docs: update metadata for #{new_version} release")
  end

  desc 'Create a zip containing all the prebuilt binaries'
  task :zip => [:clean] do
    print_info "Creating zip"

    sh %Q(mkdir -p "build")
    sh %Q(mkdir -p "build/Resources")
    sh %Q(cp -r bin build/)
    sh %Q(cp -r Templates build/)
    sh %Q(cp -r docs/docsets/Sourcery.docset build/)
    `cp LICENSE README.md CHANGELOG.md build`
    `cp Resources/daemon.gif Resources/icon-128.png build/Resources`
    `cd build; zip -r -X sourcery-#{podspec_version}.zip .`
  end

  desc 'Upload the zipped binaries to a new GitHub release'
  task :github => :zip do
    v = podspec_version

    changelog = `sed -n /'^## #{v}$'/,/'^## '/p CHANGELOG.md`.gsub(/^## .*$/,'').strip
    print_info "Releasing version #{v} on GitHub"
    puts changelog

    json = post('https://api.github.com/repos/krzysztofzablocki/Sourcery/releases', 'application/json') do |req|
      req.body = { :tag_name => v, :name => v, :body => changelog, :draft => false, :prerelease => false }.to_json
      req.basic_auth 'krzysztofzablocki', File.read('.apitoken').chomp
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

  desc 'prepare for the new development iteration'
  task :prepare_next_development_iteration do
    print_info "Preparing for the next development iteration"
    `sed -i '' -e '4 a \\
     ## Master\\
     \\
     \\
     ' CHANGELOG.md`

     print "Now review CHANGELOG.md and type [Y/n] to commit or cancel the changes. "
     manual_commit(["CHANGELOG.md"], "docs: preparing for next development iteration.")
  end
end
