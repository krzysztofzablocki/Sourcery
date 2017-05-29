## Installing

- _Binary form_

	Download latest release with prebuilt binary from [release tab](https://github.com/krzysztofzablocki/Sourcery/releases/latest). Unzip the archive into desired destination and run `bin/sourcery`

- _CocoaPods_

	Add pod 'Sourcery' to your Podfile and run `pod update Sourcery`. This will download latest release binary and will put it to your project's CocoaPods path so you will run it with `$PODS_ROOT/Sourcery/bin/sourcery`

- _Building from source_

	Download latest release source code from [release tab](https://github.com/krzysztofzablocki/Sourcery/releases/latest) or clone the repository an build Sourcery manually.

	- _Building with Swift Package Manager_

		Run `swift build -c release` in the root folder. This will create a `.build/release` folder and will put binary there. Move the **whole `.build/release` folder** to your desired destination and run with `path_to_release_folder/sourcery`

		> Note: Swift and JS templates are not supported when building with SPM yet.

	- _Building with Xcode_

		Open `Sourcery.xcworkspace` and build with `Sourcery-Release` scheme. This will create `Sourcery.app` in the Derived Data folder. You can copy it to your desired destination and run with `path_to_sourcery_app/Sourcery.app/Contents/MacOS/Sourcery`