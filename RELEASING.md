# Releasing Sourcery

There're no hard rules about when to release Sourcery. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

Following the [Semantic Versioning](http://semver.org/):
*  Increment the third number if the release has bug fixes and/or very minor features with backward compatibility, only (eg. change `0.6.0` to `0.6.1`).
*  Increment the second number if the release contains major features or breaking API changes (eg. change `0.6.1` to `0.7.0`).

### Release

Example is for releasing `0.6.1` version of the Sourcery. Make sure you've been added as owner for [CocoaPods Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk.html) and have set up the api token to be able to upload releases on GitHub via [API](https://developer.github.com/v3/#authentication).

To release a new version of the Sourcery please rake task and follow the commands.
```
rake release:new
```

It will perform the following steps:
1. Install Bundler and CocoaPods dependencies;
2. Check if the docs are up-to-date or not;
3. Check if the master branch is green on [CI](https://circleci.com/gh/krzysztofzablocki/Sourcery);
4. Run tests;
5. Ask for the new release version and updates metadata for it;
6. Create a new release on [GitHub](https://github.com/krzysztofzablocki/Sourcery/releases);
7. Push new release to [CocoaPods Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk.html);

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
