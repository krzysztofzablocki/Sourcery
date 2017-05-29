# Releasing Sourcery

There're no hard rules about when to release Sourcery. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Example is for releasing `0.6.1` version of the Sourcery. Make sure you've been added as owner for [CocoaPods Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk.html) and have set up the api token to be able to upload releases on GitHub via [API](https://developer.github.com/v3/#authentication).

Install dependencies.
```
rake install_dependencies
```

Run tests, check that all tests succeed locally and prepare the build.
```
rake tests
```

Check that the last build succeeded in [Circle CI](https://circleci.com/gh/krzysztofzablocki/Sourcery) for all supported platforms.

Update documentation.
```
rake docs
```

Commit changes.

```
git commit -am "docs: update documentation for 0.6.1 release"
git push origin master
```

#### Update metadata

Following the [Semantic Versioning](http://semver.org/):
*  Increment the third number if the release has bug fixes and/or very minor features with backward compatibility, only (eg. change `0.6.0` to `0.6.1`).
*  Increment the second number if the release contains major features or breaking API changes (eg. change `0.6.1` to `0.7.0`).

Replace Master with the new version in CHANGELOG.md.
```
### 0.6.1
```

Update Sourcery.podspec version.
```
s.version      = "0.6.1"
```

Update Sourcery command line tool version in `Sourcery/Sourcery.swift`.
```
public static let version: String = inUnitTests ? "Major.Minor.Patch" : "0.6.1"
```

Update current project version in build settings.
```
CURRENT_PROJECT_VERSION = 0.6.1
```

```
git add CHANGELOG.md
git add Sourcery.podspec
git add Sourcery/Sourcery.swift
git add Sourcery.xcodeproj/project.pbxproj
```

Commit changes.

```
git commit -m "docs: update metadata for 0.6.1 release"
git push origin master
```

Release.

```
$ rake release:new
```

### Prepare for the Next Version

Create a new `Master` header in CHANGELOG.md.

```
## Master

### New Features

### Bug fixes

### Internal changes

```

Commit your changes.

```
git add CHANGELOG.md
git commit -m "docs: preparing for next development iteration."
git push origin master
```
