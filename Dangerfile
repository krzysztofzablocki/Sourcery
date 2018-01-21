# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
not_declared_trivial = !(github.pr_title.include? "#trivial")
has_app_changes = !git.modified_files.grep(/(Sourcery|Templates)/).empty?

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Don't let testing shortcuts get into master by accident
fail("fit left in tests") if `grep -rI "fit(" SourceryTests/`.length > 1
fail("fdescribe left in tests") if `grep -rI "fdescribe(" SourceryTests/`.length > 1
fail("fcontext left in tests") if `grep -rI "fcontext(" SourceryTests/`.length > 1

# Changelog entries are required for changes to library files.
no_changelog_entry = !git.modified_files.include?("CHANGELOG.md")
if has_app_changes && no_changelog_entry && not_declared_trivial
  fail("Any changes to library code need a summary in the Changelog.")
end

# New templates must be covered with tests
has_new_stencil_template = !git.added_files.grep(/Templates\/Templates.*\.stencil$/).empty?
has_new_template_test = !git.added_files.grep(/Templates\/Tests\/Generated/).empty? && !git.added_files.grep(/Templates\/Tests\/Context/).empty? && !git.added_files.grep(/Templates\/Tests\/Expected/).empty?
if has_new_stencil_template && !has_new_template_test
  fail("Any new stencil template must be covered with test.")
end

jazzy.check fail: :modified
