## Installing

- _Binary form_

	The easiest way to download the tool right now is to just grab a newest `.zip` distribution from [releases tab](https://github.com/krzysztofzablocki/Sourcery/releases).

- _Via CocoaPods_

	If you're using CocoaPods, you can simply add pod 'Sourcery' to your Podfile.

	This will download the Sourcery binaries and dependencies in `Pods/`.
You just need to add `$PODS_ROOT/Sourcery/bin/sourcery {source} {templates} {output}` in your Script Build Phases.

- _Via Swift Package Manager_

	If you're using SwiftPM, you can simply add 'Sourcery' to your manifest.

	Sourcery is placed in `Packages`.
After your first `swift build`, you can run `.build/debug/sourcery {source} {templates} {output}`.

- _From Source_

	You can clone it from the repo and just run `Sourcery.xcworkspace`.

