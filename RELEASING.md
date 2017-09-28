# Releasing Sourcery

There're no hard rules about when to release Sourcery. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

Following the [Semantic Versioning](http://semver.org/):
*  Increment the third number if the release has bug fixes and/or very minor features with backward compatibility, only (eg. change `0.6.0` to `0.6.1`).
*  Increment the second number if the release contains major features or breaking API changes (eg. change `0.6.1` to `0.7.0`).

Make sure you've been added as owner for [CocoaPods Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk.html) and have push access to the [Sourcery](https://github.com/krzysztofzablocki/Sourcery) repository.

To create automatic GitHub releases, set up [API Token](https://github.com/settings/tokens/new). We recommend giving the token the smallest scope possible. This means just `public_repo`. After getting the token add the following ENV variables:

```
export SOURCERY_GITHUB_USERNAME=YOUR_GITHUB_USERNAME
export SOURCERY_GITHUB_API_TOKEN=YOUR_TOKEN
```

To be able to release a [Homebrew](https://github.com/Homebrew/homebrew-core) formula update, install [brew](https://brew.sh/).

### Release

Example is for releasing `0.6.1` version of the Sourcery.

To release a new version of the Sourcery please rake task and follow the commands.
```
rake release:new
```

It will perform the following steps:
1. Install Bundler and CocoaPods dependencies;
2. Check if the docs are up-to-date or not;
3. Check if the master branch is green on [CI](https://circleci.com/gh/krzysztofzablocki/Sourcery);
4. Update internal boilerplate code;
5. Run tests;
6. Ask for the new release version and updates metadata for it;
7. Create a new release on [GitHub](https://github.com/krzysztofzablocki/Sourcery/releases);
8. Push new release to [CocoaPods Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk.html);
9. Push new formula to [Homebrew](https://github.com/Homebrew/homebrew-core), this will ask you for manual input of your username and password to open a GitHub PR;
10. Prepare a new development iteration.

Some tasks require manual approvement or input, please pay attention to the automatic changes before confirming them.
