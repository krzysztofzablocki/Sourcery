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
task :test_templates do
  print_info "Running Sourcery Templates Tests"
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme Sourcery -sdk macosx)
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme TemplatesTests -sdk macosx test)
end

desc "Run the Unit Tests on all projects"
task :tests do
  print_info "Running Unit Tests"
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme Sourcery -sdk macosx)
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme Sourcery -sdk macosx test)
end

desc "Delete the build/ directory"
task :clean do
  print_info "Cleaning build folder"
  sh %Q(rm -fr build)
end

task :build do
  print_info "Building project"
  xcrun %Q(xcodebuild -workspace Sourcery.xcworkspace -scheme Sourcery-Release -sdk macosx -derivedDataPath #{BUILD_DIR}tmp/)
  sh %Q(rm -fr bin/Sourcery.app)
  `mv #{BUILD_DIR}tmp/Build/Products/Release/Sourcery.app bin/`
  sh %Q(rm -fr #{BUILD_DIR}tmp/)
end

## [ Code Generated ] ################################################

task :run_sourcery do
  print_info "Generating internal boilerplate code"
  sh "bin/sourcery --sources './Sources/' --templates './Sourcery/Templates/' --output './SourceryRuntime/Sources/'"
end

desc "Update internal boilerplate code"
task :generate_internal_boilerplate_code => [:build, :run_sourcery, :clean] do
  generated_files = [
    "SourceryRuntime/Sources/Coding.generated.swift",
    "SourceryRuntime/Sources/Description.generated.swift",
    "SourceryRuntime/Sources/Diffable.generated.swift",
    "SourceryRuntime/Sources/Equality.generated.swift",
    "SourceryRuntime/Sources/JSExport.generated.swift",
    "SourceryRuntime/Sources/Typed.generated.swift",
    "SourceryTests/Models/TypedSpec.generated.swift"
  ]
  print_info "Now review and type [Y/n] to commit and push or cancel the changes."
  print "Updated files:\n#{generated_files.join("\n")}\n"
  manual_commit(generated_files, "update internal boilerplate code.")
end

## [ Docs ] ##########################################################

desc "Update docs"
task :docs do
  print_info "Updating docs"
  temp_build_dir = "#{BUILD_DIR}tmp/"
  sh "sourcekitten doc --module-name SourceryRuntime -- -workspace Sourcery.xcworkspace -scheme Sourcery-Release -derivedDataPath #{temp_build_dir} > docs.json && bundle exec jazzy --clean --skip-undocumented --exclude=/*/*.generated.swift,/*/BytesRange.swift,/*/Typealias.swift,/*/FileParserResult.swift && rm docs.json"
  sh "rm -fr #{temp_build_dir}"
end

desc "Validate docs"
task :validate_docs do
  print_info "Checking docs are up to date"
  temp_build_dir = "#{BUILD_DIR}tmp/"
  sh "sourcekitten doc --module-name SourceryRuntime -- -workspace Sourcery.xcworkspace -scheme Sourcery-Release -derivedDataPath #{temp_build_dir} > docs.json && bundle exec jazzy --skip-undocumented --no-download-badge --exclude=/*/*.generated.swift,/*/BytesRange.swift,/*/Typealias.swift,/*/FileParserResult.swift && rm docs.json"
  sh "rm -fr #{temp_build_dir}"
end

## [ Release ] ##########################################################

namespace :release do
  desc 'Create a new release on GitHub, CocoaPods and Homebrew'
  task :new => [:clean, :install_dependencies, :check_environment_variables, :check_docs, :check_ci,  :update_metadata, :generate_internal_boilerplate_code, :tests, :build, :check_versions, :tag_release, :github, :cocoapods, :homebrew]

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

  def project_update_version(version, project = 'Sourcery')
    `sed -i '' -e 's/CURRENT_PROJECT_VERSION = #{project_version(project)};/CURRENT_PROJECT_VERSION = #{version};/g' #{project}.xcodeproj/project.pbxproj`
  end

  def project_version(project = 'Sourcery')
    `xcodebuild -showBuildSettings -project #{project}.xcodeproj | grep CURRENT_PROJECT_VERSION | sed -E  's/(.*) = (.*)/\\2/'`.strip
  end

  def command_line_tool_update_version(version, file = 'Sourcery/Version.swift')
    version_content = File.read(file)
    version_regex = /(?<begin>public static let current\s*=\s*Version\(value:\s*")(?<value>(?<major>[0-9]+)(\.(?<minor>[0-9]+))?(\.(?<patch>[0-9]+))?)(?<end>"\))/i
    version_match = version_regex.match(version_content)
    updated_version_content = version_content.gsub(version_regex, "#{version_match[:begin]}#{version}#{version_match[:end]}")
    File.open(file, "w") { |f| f.puts updated_version_content }
  end

  def command_line_tool_version(file = 'Sourcery/Version.swift')
    version_content = File.read(file)
    version_regex = /(?<begin>public static let current\s*=\s*Version\(value:\s*")(?<value>(?<major>[0-9]+)(\.(?<minor>[0-9]+))?(\.(?<patch>[0-9]+))?)(?<end>"\))/i
    version_match = version_regex.match(version_content)
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
    commit_changes = STDIN.gets.chomp == 'Y'
    if commit_changes then
      system(%Q{git add #{files.join(" ")}})
      system(%Q{git commit -m '#{message}'})
    else
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

    # Check if Command Line Tool version match podspec version
    results << log_result(version == command_line_tool_version, "Command line tool version correct", "Please update current version in Sourcery/Version.swift to #{version}")

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
    podspec_update_version(new_version)

    # Update project version
    project_update_version(new_version)

    # Update command line tool version
    command_line_tool_update_version(new_version)

    print "Now review and type [Y/n] to commit and push or cancel the changes. "
    manual_commit(["CHANGELOG.md", "Sourcery.podspec", "Sourcery.xcodeproj/project.pbxproj", "Sourcery/Version.swift"], "docs: update metadata for #{new_version} release")
    git_push
  end

  desc 'Create a tag for the project version and push to remote'
  task :tag_release do
    print_info "Tagging the release"
    git_tag(project_version)
    git_push
  end


  desc 'Create a zip containing all the prebuilt binaries'
  task :zip => [:clean] do
    print_info "Creating zip"

    sh %Q(mkdir -p "build")
    sh %Q(mkdir -p "build/Resources")
    sh %Q(cp -r bin build/)
    sh %Q(cp -r Templates/Templates build/)
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
      req.basic_auth ENV['SOURCERY_GITHUB_USERNAME'], ENV['SOURCERY_GITHUB_API_TOKEN'].chomp
    end

    upload_url = json['upload_url'].gsub(/\{.*\}/,"?name=Sourcery-#{v}.zip")
    zipfile = "build/Sourcery-#{v}.zip"
    zipsize = File.size(zipfile)

    print_info "Uploading ZIP (#{zipsize} bytes)"
    post(upload_url, 'application/zip') do |req|
      req.body_stream = File.open(zipfile, 'rb')
      req.add_field('Content-Length', zipsize)
      req.add_field('Content-Transfer-Encoding', 'binary')
      req.basic_auth ENV['SOURCERY_GITHUB_USERNAME'], ENV['SOURCERY_GITHUB_API_TOKEN'].chomp
    end
  end

  desc 'pod trunk push Sourcery to CocoaPods'
  task :cocoapods do
    print_info "Pushing pod to CocoaPods Trunk"
    sh 'bundle exec pod trunk push Sourcery.podspec --allow-warnings'
  end

  desc 'send a PR to homebrew'
  task :homebrew do
    print_info "Releasing to homebrew"
    formulas_dir = `brew --repository homebrew/core`.chomp
    formula_file = "./Formula/sourcery.rb"
    version = project_version
    branch = "sourcery-#{version}"

    Dir.chdir(formulas_dir) do
      sh "git checkout master"
      sh "git pull origin master"
      sh "git checkout -b #{branch} origin/master"

      print_info "Updating Homebrew formula"
      targz_url = sourcery_targz_url(version)
      sha256 = extract_sha256(targz_url)
      formula = File.read(formula_file)
      new_formula = formula.gsub(/url "https:.*"$/, %Q(url "#{targz_url}")).gsub(/sha256 ".*"$/,%Q(sha256 "#{sha256.to_s}"))
      File.open(formula_file, "w") { |f| f.puts new_formula }

      print_info "Checking Homebrew formula"
      sh "brew install --build-from-source #{formula_file}"
      sh "brew audit --strict --online #{formula_file}"
      sh "brew test #{formula_file}"

      print_info "Pushing to Homebrew"
      sh "git checkout #{formula_file}"
      sh "git checkout master"
      sh "git branch #{branch} -D"
      sh "brew bump-formula-pr --url='#{targz_url}' --sha256='#{sha256.to_s}' #{formula_file}"
    end
  end

  desc 'prepare for the new development iteration'
  task :prepare_next_development_iteration do
    print_info "Preparing for the next development iteration"
    `sed -i '' -e '4 a \\
     ## Master\\
     \\
     \\
     ' CHANGELOG.md`

     print "Now review CHANGELOG.md and type [Y/n] to commit and push or cancel the changes. "
     manual_commit(["CHANGELOG.md"], "docs: preparing for next development iteration.")
     git_push
  end
end
