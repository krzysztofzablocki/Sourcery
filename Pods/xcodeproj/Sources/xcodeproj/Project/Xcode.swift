import Foundation

/// Class that contains Xcode constants.
public struct Xcode {
    /// Last known constants.
    public struct LastKnown {
        /// Last known SDKs.
        public struct SDK {
            /// Last known SDK for iOS.
            public static let ios: String = "12.0"

            /// Last known SDK for macOS.
            public static let macos: String = "10.14"

            /// Last known SDK for tvOS.
            public static let tvos: String = "12.0"

            /// Last known SDK for watchos.
            public static let watchos: String = "5.0"
        }

        /// Last known archive version for Xcodeproj.
        public static let archiveVersion: UInt = 1

        /// Last known Swift version (stable).
        public static let swiftVersion = "4.2"

        /// Last known object version for Xcodeproj.
        public static let objectVersion: UInt = 51

        /// Last known upgrade check.
        public static let upgradeCheck = "1000"

        /// Last known Swift upgrade check.
        public static let swiftUpgradeCheck = "1000"
    }

    /// Default values.
    public struct Default {
        /// The default object version for Xcodeproj.
        public static let objectVersion: UInt = 52 // Xcode 11

        /// Default compatibility version.
        public static let compatibilityVersion: String = "Xcode 9.3"

        /// Default development region.
        public static let developmentRegion: String = "en"
    }

    /// Inherited keywords used in build settings.
    public static let inheritedKeywords = ["${inherited}", "$(inherited)"]

    /// Header files extensions.
    public static let headersExtensions = [".h", ".hh", ".hpp", ".ipp", ".tpp", ".hxx", ".def", ".inl", ".inc"]

    /// Supported values.
    public struct Supported {
        /// The version of `.xcscheme` files supported by Xcodeproj
        public static let xcschemeFormatVersion = "1.3"
    }

    /// Returns the Xcode file type for any given extension.
    ///
    /// - Parameter extension: file extension.
    /// - Returns: Xcode file type.
    public static func filetype(extension: String) -> String? {
        return [
            "a": "archive.ar",
            "apns": "text",
            "app": "wrapper.application",
            "appex": "wrapper.app-extension",
            "bundle": "wrapper.plug-in",
            "dylib": "compiled.mach-o.dylib",
            "entitlements": "text.plist.entitlements",
            "framework": "wrapper.framework",
            "gif": "image.gif",
            "gpx": "text.xml",
            "h": "sourcecode.c.h",
            "m": "sourcecode.c.objc",
            "markdown": "text",
            "mdimporter": "wrapper.cfbundle",
            "modulemap": "sourcecode.module",
            "mov": "video.quicktime",
            "mp3": "audio.mp3",
            "octest": "wrapper.cfbundle",
            "pch": "sourcecode.c.h",
            "plist": "text.plist.xml",
            "png": "image.png",
            "sh": "text.script.sh",
            "sks": "file.sks",
            "storyboard": "file.storyboard",
            "strings": "text.plist.strings",
            "swift": "sourcecode.swift",
            "xcassets": "folder.assetcatalog",
            "xcconfig": "text.xcconfig",
            "xcdatamodel": "wrapper.xcdatamodel",
            "xcodeproj": "wrapper.pb-project",
            "xctest": "wrapper.cfbundle",
            "xib": "file.xib",
            "zip": "archive.zip",
        ][`extension`]
    }
}
