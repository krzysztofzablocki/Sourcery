#!/usr/bin/rake
## Most of this code is adapted from Sourcery https://github.com/AliSoftware/Sourcery/blob/master/Rakefile

require 'pathname'
require 'yaml'
require 'json'
require 'net/http'
require 'uri'
require 'rbconfig'

BUILD_DIR = 'build/'
CLI_DIR = 'cli/'
VERSION_FILE = 'SourceryUtils/Sources/Version.swift'

## [ Utils ] ##################################################################
def version_select
  latest_xcode_version = `xcode-select -p`.chomp
  %Q(DEVELOPER_DIR="#{latest_xcode_version}" TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault.xctoolchain)
end

def xcpretty(cmd)
  if `which xcpretty` && $?.success?
    sh "set -o pipefail && #{cmd} | xcpretty -c"
  else
    sh cmd
  end
end

def print_info(str)
  (red,clr) = (`tput colors`.chomp.to_i >= 8) ? %W(\e[33m \e[m) : ["", ""]
  puts red, "== #{str.chomp} ==", clr
end

## [ Bundler ] ####################################################

desc "Install dependencies"
task :install_dependencies do
  sh %Q(bundle install)
end

## [ Tests & Clean ] ##########################################################

desc "Run the Unit Tests on all projects"
task :tests do
  print_info "Running Unit Tests"
  sh %Q(swift test)
end

desc "Delete the build/ directory"
task :clean do
  print_info "Cleaning build folder"
  sh %Q(rm -fr build)
end

def build_framework(fat_library)
  print_info "Building project (fat: #{fat_library})"

  # Prepare the export directory
  sh %Q(rm -fr #{CLI_DIR})
  sh %Q(mkdir -p "#{CLI_DIR}bin")
  output_path="#{CLI_DIR}bin/sourcery"

  if fat_library
    sh %Q(swift build --disable-sandbox -c release --arch arm64 --build-path #{BUILD_DIR})
    sh %Q(swift build --disable-sandbox -c release --arch x86_64 --build-path #{BUILD_DIR})
    sh %Q(lipo -create -output #{output_path} #{BUILD_DIR}arm64-apple-macosx/release/sourcery #{BUILD_DIR}x86_64-apple-macosx/release/sourcery)
    sh %Q(strip -rSTX #{output_path})
  else
    sh %Q(swift build --disable-sandbox -c release --build-path #{BUILD_DIR})
    sh %Q(cp #{BUILD_DIR}release/sourcery #{output_path})
  end

  # Export the build products and clean up
  sh %Q(cp SourceryJS/Resources/ejs.js #{CLI_DIR}bin)
  sh %Q(rm -fr #{BUILD_DIR})
end

task :build do
  build_framework(false)
end

task :fat_build do
  build_framework(true)
end

## [ Code Generated ] ################################################

task :run_sourcery do
  print_info "Generating internal boilerplate code"
  sh "#{CLI_DIR}bin/sourcery --config .sourcery-macOS.yml"
  sh "#{CLI_DIR}bin/sourcery --config .sourcery-ubuntu.yml"
end

desc "Update internal boilerplate code"
task :generate_internal_boilerplate_code => [:build, :run_sourcery] do
  sh "Scripts/package_content \"SourceryRuntime/Sources/Common,SourceryRuntime/Sources/macOS,SourceryRuntime/Sources/Generated\" \"true\" > \"SourcerySwift/Sources/SourceryRuntime.content.generated.swift\""
  sh "Scripts/package_content \"SourceryRuntime/Sources/Common,SourceryRuntime/Sources/Linux,SourceryRuntime/Sources/Generated\" \"false\" > \"SourcerySwift/Sources/SourceryRuntime_Linux.content.generated.swift\""
  generated_files = `git status --porcelain`
                      .split("\n")
                      .select { |item| item.include?('.generated.') }
                      .map { |item| item.split.last }
  manual_commit(generated_files, "update internal boilerplate code.")
end

## [ Docs ] ##########################################################
def clean_jazzy
  # jazzy divs are broken, so we need to fix them
  sh "find docs -type f -name '*.html' -print0 | xargs -0 -I % sh -c \"tac '%' | sed '2d' | tac > tmp && mv tmp '%';\""
end

desc "Update docs"
task :docs do
  print_info "Updating docs"
  temp_build_dir = "#{BUILD_DIR}tmp/"
  # tac Enum.html | sed '2d' | tac > Enum.html
  sh "bundle exec sourcekitten doc --spm --module-name SourceryRuntime > docs.json && bundle exec jazzy --clean --skip-undocumented && rm docs.json"
  clean_jazzy
  sh "rm -fr #{temp_build_dir}"
end

desc "Validate docs"
task :validate_docs do
  print_info "Checking docs are up to date"
  temp_build_dir = "#{BUILD_DIR}tmp/"
  ## TODO: RA this step is disabled due to error comming only on CI and only sometimes locally:
  ## [1/1] Compiling plugin SourceryCommandPlugin
  ## Building for debugging...
  ## error: command /Users/art-divin/Documents/Projects/Sourcery/.build/arm64-apple-macosx/debug/Sourcery_SourceryJS.bundle/ejs.js not registered
  ## [1/12] Copying ejs.js
  ## [1/12] Compiling scanner.c
  ## ...
  #sh "bundle exec sourcekitten doc --spm --module-name SourceryRuntime -- --very-verbose > docs.json && bundle exec jazzy --skip-undocumented && rm docs.json"
  ## clean_jazzy
  sh "rm -fr #{temp_build_dir}"
end

## [ Release ] ##########################################################

namespace :release do

  desc 'Perform pre-release tasks'
  task :prepare => [:clean, :install_dependencies, :check_environment_variables, :check_docs, :update_metadata, :generate_internal_boilerplate_code, :tests]

  desc 'Build the current version and release it to GitHub, CocoaPods'
  task :build_and_deploy => [:check_versions, :fat_build, :tag_release, :push_to_origin, :github, :cocoapods]

  desc 'Create a new release on GitHub, CocoaPods'
  task :new => [:prepare, :build_and_deploy]

  def podspec_update_version(version, file = 'Sourcery.podspec')
    # The code is mainly taken from https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/helper/podspec_helper.rb
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

  VERSION_REGEX = /(?<begin>public static let current\s*=\s*SourceryVersion\(value:\s*.*")(?<value>(?<major>[0-9]+)(\.(?<minor>[0-9]+))?(\.(?<patch>[0-9]+))?)(?<end>"\))/i.freeze

  def command_line_tool_update_version(version, file = VERSION_FILE)
    version_content = File.read(file)
    version_match = VERSION_REGEX.match(version_content)
    updated_version_content = version_content.gsub(VERSION_REGEX, "#{version_match[:begin]}#{version}#{version_match[:end]}")
    File.open(file, "w") { |f| f.puts updated_version_content }
  end

  def command_line_tool_version(file = VERSION_FILE)
    version_content = File.read(file)
    version_match = VERSION_REGEX.match(version_content)
    version_match[:value]
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
    unless response.code == '201' || response.code == '202'
      puts "Error: #{response.code} - #{response.message}"
      puts response.body
      exit 3
    end
    JSON.parse(response.body)
  end

  def manual_commit(files, message)
    print_info "Preparing commit"
    system(%Q{git --no-pager diff #{files.join(" ")}})
    print "Now review the above diff. Do you wish to commit the changes? [Y/n] "
    commit_changes = STDIN.gets.chomp == 'Y'
    if commit_changes then
      system(%Q{git add #{files.join(" ")}})
      system(%Q{git commit -m '#{message}'})
    else
      puts "Aborting commit, checkout pending changes"
      system(%Q{git checkout #{files.join(" ")}})
      exit 2
    end
  end

  def git_tag(tag)
    system(%Q{git tag #{tag}})
  end

  def git_push(remote = 'origin', branch = 'master')
    system(%Q{git push #{remote} #{branch} --tags})
  end

  def sourcery_targz_url(version)
    "https://github.com/krzysztofzablocki/Sourcery/archive/#{version}.tar.gz"
  end

  def extract_sha256(archive_url)
    sha256_res = `curl -L #{archive_url} | shasum -a 256`
    sha256 = /^[A-Fa-f0-9]+/.match(sha256_res)
    if sha256.nil? then
      print "Unable to extract SHA256"
      exit 3
    end
    sha256
  end

  desc 'Check ENV variables required for release'
  task :check_environment_variables do
    print_info "Checking ENV variables"
    results = []

    results << log_result(!ENV['SOURCERY_GITHUB_USERNAME'].nil?, "SOURCERY_GITHUB_USERNAME is set up", "Please add SOURCERY_GITHUB_USERNAME environment variable")
    results << log_result(!ENV['SOURCERY_GITHUB_API_TOKEN'].nil?, "SOURCERY_GITHUB_API_TOKEN is set up", "Please add SOURCERY_GITHUB_API_TOKEN environment variable")

    exit 1 unless results.all?
  end

  desc 'Check if CI is green'
  task :check_ci do
    print_info "Checking Circle CI master branch status"
    results = []

    json = get('https://circleci.com/api/v1.1/project/github/krzysztofzablocki/Sourcery/tree/master')
    master_branch_status = json[0]['status']
    results << log_result(master_branch_status == 'success' || master_branch_status == 'fixed', 'Master branch is green on CI', 'Please check master branch CI status first')
    exit 1 unless results.all?
  end

  desc 'Check if docs are up to date'
  task :check_docs => [:validate_docs] do
    results = []

    docs_not_changed = `git diff --name-only docs` == ""
    results << log_result(docs_not_changed, 'Docs are up to date', 'Please push updated docs first')
    exit 1 unless results.all?
  end

  desc 'Check if all versions from the podspecs, CHANGELOG and build settings match'
  task :check_versions do
    print_info "Checking versions match"
    results = []

    # Check if bundler is installed first, as we'll need it for the cocoapods task (and we prefer to fail early)
    `which bundle`
    results << log_result( $?.success?, 'Bundler installed', 'Please install bundler using `gem install bundler` and run `bundle install` first.')

    # Extract version from Sourcery.podspec
    version = podspec_version
    puts "#{'Sourcery.podspec'.ljust(25)} \u{1F449}  #{version}"

    # Check if entry present in CHANGELOG
    changelog_entry = system(%Q{grep -q '^## #{Regexp.quote(version)}$' CHANGELOG.md})
    results << log_result(changelog_entry, "CHANGELOG, Entry added", "Please add an entry for #{version} in CHANGELOG.md")

    changelog_master = system(%q{grep -qi '^## Master' CHANGELOG.md})
    results << log_result(!changelog_master, "CHANGELOG, No master", 'Please remove entry for master in CHANGELOG')

    # Check if Command Line Tool version match podspec version
    results << log_result(version == command_line_tool_version, "Command line tool version correct", "Please update current version in #{VERSION_FILE} to #{version}")

    exit 1 unless results.all?

    print "Release version #{version} [Y/n]? "
    exit 2 unless (STDIN.gets.chomp == 'Y')
  end

  desc 'Updates metadata for the new release'
  task :update_metadata do
    print "New version of Sourcery in sematic format major.minor.patch? "
    new_version = STDIN.gets.chomp
    unless new_version =~ /^\d+\.\d+\.\d+$/ then
      print "Please set version following the semantic format http://semver.org/\n"
      exit 3
    end

    print_info "Updating metadata for #{new_version} release\n"

    # Replace master with the new release version in CHANGELOG.md
    system(%Q{sed -i '' -e 's/## Master/## #{new_version}/' CHANGELOG.md})

    # Update podspec version
    podspec_update_version(new_version, 'Sourcery.podspec')
    podspec_update_version(new_version, 'SourceryFramework.podspec')
    podspec_update_version(new_version, 'SourceryRuntime.podspec')
    podspec_update_version(new_version, 'SourceryUtils.podspec')

    # Update command line tool version
    command_line_tool_update_version(new_version)

    manual_commit(["CHANGELOG.md", "Sourcery.podspec", "SourceryFramework.podspec", "SourceryRuntime.podspec", "SourceryUtils.podspec", VERSION_FILE], "docs: update metadata for #{new_version} release")
  end

  desc 'Create a tag for the project version and push to remote'
  task :tag_release do
    print_info "Tagging the release"
    git_tag(podspec_version)
  end


  desc 'Create a zip containing all the prebuilt binaries'
  task :zip => [:clean] do
    print_info "Creating zip"

    sh %Q(mkdir -p "build")
    sh %Q(mkdir -p "build/sourcery")
    sh %Q(mkdir -p "build/sourcery/Resources")
    sh %Q(cp -r #{CLI_DIR} build/sourcery/)
    sh %Q(cp -r Templates/Templates build/sourcery/)
    sh %Q(cp -r docs/docsets/Sourcery.docset build/sourcery/)
    `cp LICENSE README.md CHANGELOG.md build/sourcery`
    `cp Resources/daemon.gif Resources/icon-128.png build/sourcery/Resources`
    `cd build/sourcery; zip -r -X ../sourcery-#{podspec_version}.zip .`
  end

  desc 'Create a zip containing all the prebuilt binaries in the artifact bundle format (for SwiftPM Package Plugins)'
  task :artifactbundle => :zip do
    bundle_dir = 'build/sourcery.artifactbundle'
    bin_dir = "#{bundle_dir}/sourcery/bin"

    # Copy the built product to an artifact bundle
    `mkdir -p #{bin_dir}`
    `cp -Rf build/sourcery #{bin_dir}`

    # Write the `info.json` artifact bundle manifest
    info_template = File.read("Templates/artifactbundle.info.json.template")
    info_file_content = info_template.gsub(/(VERSION)/, podspec_version)

    File.open("#{bundle_dir}/info.json", "w") do |f|
      f.write(info_file_content)
    end

    # Zip the bundle
    `cd build; zip -r -X sourcery-#{podspec_version}.artifactbundle.zip sourcery.artifactbundle/`
  end

  def upload_zip(filename)
    upload_url = json['upload_url'].gsub(/\{.*\}/, "?name=#{filename}")
    zipfile = "build/#{filename}"
    zipsize = File.size(zipfile)

    print_info "Uploading ZIP (#{zipsize} bytes)"
    post(upload_url, 'application/zip') do |req|
      req.body_stream = File.open(zipfile, 'rb')
      req.add_field('Content-Length', zipsize)
      req.add_field('Content-Transfer-Encoding', 'binary')
      req.basic_auth ENV['SOURCERY_GITHUB_USERNAME'], ENV['SOURCERY_GITHUB_API_TOKEN'].chomp
    end
  end

  desc 'Upload the zipped binaries to a new GitHub release'
  task :github => :artifactbundle do
    v = podspec_version

    changelog = `sed -n /'^## #{v}$'/,/'^## '/p CHANGELOG.md`.gsub(/^## .*$/,'').strip
    print_info "Releasing version #{v} on GitHub"
    puts changelog

    json = post('https://api.github.com/repos/krzysztofzablocki/Sourcery/releases', 'application/json') do |req|
      req.body = { :tag_name => v, :name => v, :body => changelog, :draft => false, :prerelease => false }.to_json
      req.basic_auth ENV['SOURCERY_GITHUB_USERNAME'], ENV['SOURCERY_GITHUB_API_TOKEN'].chomp
    end

    upload_zip("Sourcery-#{v}.zip")
    upload_zip("Sourcery-#{v}.artifactbundle.zip")
  end

  desc 'pod trunk push Sourcery to CocoaPods'
  task :cocoapods do
    print_info "Pushing pod to CocoaPods Trunk"
    sh 'bundle exec pod trunk push Sourcery.podspec --allow-warnings --verbose --skip-tests'
  end

  desc 'Push the pending master changes to origin'
  task :push_to_origin do
    git_push
  end

  desc 'prepare for the new development iteration'
  task :prepare_next_development_iteration do
    print_info "Preparing for the next development iteration"
    `sed -i '' -e '3 a \\
     ## Master\\
     \\
     \\
     ' CHANGELOG.md`

     manual_commit(["CHANGELOG.md"], "docs: preparing for next development iteration.")
  end
end
