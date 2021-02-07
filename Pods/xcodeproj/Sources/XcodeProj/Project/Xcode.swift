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
        public static let objectVersion: UInt = 54

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
        allExtensions[`extension`]
    }

    // Derived from Xcode3Core.ideplugin in Xcode 11.1
    // - DevToolsCore.framework/Versions/A/Resources/BuiltInFileTypes.xcspec
    // - DevToolsCore.framework/Versions/A/Resources/StandardFileTypes.xcspec
    // - Core Data.xcplugin/Contents/Resources/Core Data.pbfilespec
    // - CoreBuildTasks.xcplugin/Contents/Resources/InstrumentsPackage.xcspec
    // - Intents.xcplugin/Contents/Resources/Intents.pbfilespec
    // - Metal.xcplugin/Contents/Resources/FileTypes.xcspec
    // - RCBuildSystemSupport.xcplugin/Contents/Resources/RCFileTypes.pbfilespec
    // - SceneKit.xcplugin/Contents/Resources/SceneKit FileTypes.xcspec
    // - SpriteKit.xcplugin/Contents/Resources/SpriteKitFileTypes.xcspec
    // - XCLanguageSupport.xcplugin/Contents/Resources/Swift.pbfilespec
    private static let allExtensions = [
        "1": "text.man",
        "C": "sourcecode.cpp.cpp",
        "H": "sourcecode.cpp.h",
        "M": "sourcecode.cpp.objcpp",
        "a": "archive.ar",
        "ada": "sourcecode.ada",
        "adb": "sourcecode.ada",
        "ads": "sourcecode.ada",
        "aiff": "audio.aiff",
        "air": "compiled.air",
        "apinotes": "text.apinotes",
        "apns": "text",
        "app": "wrapper.application",
        "appex": "wrapper.app-extension",
        "applescript": "sourcecode.applescript",
        "archivingdescription": "text.xml.ibArchivingDescription",
        "asdictionary": "archive.asdictionary",
        "asm": "sourcecode.asm.asm",
        "atlas": "folder.skatlas",
        "au": "audio.au",
        "avi": "video.avi",
        "bin": "archive.macbinary",
        "bmp": "image.bmp",
        "bundle": "wrapper.cfbundle",
        "c": "sourcecode.c.c",
        "c++": "sourcecode.cpp.cpp",
        "cc": "sourcecode.cpp.cpp",
        "cdda": "audio.aiff",
        "cl": "sourcecode.opencl",
        "class": "compiled.javaclass",
        "classdescription": "text.plist.ibClassDescription",
        "classdescriptions": "text.plist.ibClassDescription",
        "clp": "sourcecode.clips",
        "cp": "sourcecode.cpp.cpp",
        "cpp": "sourcecode.cpp.cpp",
        "csh": "text.script.csh",
        "css": "text.css",
        "ctrl": "sourcecode.glsl",
        "cxx": "sourcecode.cpp.cpp",
        "d": "sourcecode.dtrace",
        "dSYM": "wrapper.dsym",
        "dae": "text.xml.dae",
        "defs": "sourcecode.mig",
        "dext": "wrapper.driver-extension",
        "dict": "text.plist",
        "dsym": "wrapper.dsym",
        "dtd": "text.xml",
        "dylan": "sourcecode.dylan",
        "dylib": "compiled.mach-o.dylib",
        "ear": "archive.ear",
        "entitlements": "text.plist.entitlements",
        "eval": "sourcecode.glsl",
        "exp": "sourcecode.exports",
        "f": "sourcecode.fortran",
        "f77": "sourcecode.fortran.f77",
        "f90": "sourcecode.fortran.f90",
        "f95": "sourcecode.fortran.f90",
        "for": "sourcecode.fortran",
        "frag": "sourcecode.glsl",
        "fragment": "sourcecode.glsl",
        "framework": "wrapper.framework",
        "fs": "sourcecode.glsl",
        "fsh": "sourcecode.glsl",
        "geom": "sourcecode.glsl",
        "geometry": "sourcecode.glsl",
        "gif": "image.gif",
        "gmk": "sourcecode.make",
        "gpx": "text.xml",
        "gs": "sourcecode.glsl",
        "gsh": "sourcecode.glsl",
        "gz": "archive.gzip",
        "h": "sourcecode.c.h",
        "h++": "sourcecode.cpp.h",
        "hh": "sourcecode.cpp.h",
        "hp": "sourcecode.cpp.h",
        "hpp": "sourcecode.cpp.h",
        "hqx": "archive.binhex",
        "htm": "text.html",
        "html": "text.html",
        "htmld": "wrapper.htmld",
        "hxx": "sourcecode.cpp.h",
        "i": "sourcecode.c.c.preprocessed",
        "icns": "image.icns",
        "ico": "image.ico",
        "iconset": "folder.iconset",
        "ii": "sourcecode.cpp.cpp.preprocessed",
        "iig": "sourcecode.iig",
        "imagecatalog": "folder.imagecatalog",
        "inc": "sourcecode.pascal",
        "instrdst": "com.apple.instruments.instrdst",
        "instrpkg": "com.apple.instruments.package-definition",
        "intentdefinition": "file.intentdefinition",
        "ipp": "sourcecode.cpp.h",
        "jam": "sourcecode.jam",
        "jar": "archive.jar",
        "java": "sourcecode.java",
        "javascript": "sourcecode.javascript",
        "jpeg": "image.jpeg",
        "jpg": "image.jpeg",
        "js": "sourcecode.javascript",
        "jscript": "sourcecode.javascript",
        "json": "text.json",
        "jsp": "text.html.other",
        "kext": "wrapper.kernel-extension",
        "l": "sourcecode.lex",
        "lid": "sourcecode.dylan",
        "ll": "sourcecode.asm.llvm",
        "llx": "sourcecode.asm.llvm",
        "lm": "sourcecode.lex",
        "lmm": "sourcecode.lex",
        "lp": "sourcecode.lex",
        "lpp": "sourcecode.lex",
        "lxx": "sourcecode.lex",
        "m": "sourcecode.c.objc",
        "mak": "sourcecode.make",
        "make": "sourcecode.make",
        "map": "sourcecode.module-map",
        "markdown": "net.daringfireball.markdown",
        "md": "net.daringfireball.markdown",
        "mdimporter": "wrapper.spotlight-importer",
        "mdown": "net.daringfireball.markdown",
        "metal": "sourcecode.metal",
        "metallib": "archive.metal-library",
        "mi": "sourcecode.c.objc.preprocessed",
        "mid": "audio.midi",
        "midi": "audio.midi",
        "mig": "sourcecode.mig",
        "mii": "sourcecode.cpp.objcpp.preprocessed",
        "mlkitmodel": "file.mlmodel",
        "mlmodel": "file.mlmodel",
        "mm": "sourcecode.cpp.objcpp",
        "modulemap": "sourcecode.module-map",
        "moov": "video.quicktime",
        "mov": "video.quicktime",
        "mp3": "audio.mp3",
        "mpeg": "video.mpeg",
        "mpg": "video.mpeg",
        "mpkg": "wrapper.installer-mpkg",
        "nasm": "sourcecode.nasm",
        "nib": "wrapper.nib",
        "nib~": "wrapper.nib",
        "nqc": "sourcecode.nqc",
        "o": "compiled.mach-o.objfile",
        "octest": "wrapper.cfbundle",
        "p": "sourcecode.pascal",
        "pas": "sourcecode.pascal",
        "pbfilespec": "text.plist.pbfilespec",
        "pblangspec": "text.plist.pblangspec",
        "pbxproj": "text.pbxproject",
        "pch": "sourcecode.c.h",
        "pch++": "sourcecode.cpp.h",
        "pct": "image.pict",
        "pdf": "image.pdf",
        "perl": "text.script.perl",
        "php": "text.script.php",
        "php3": "text.script.php",
        "php4": "text.script.php",
        "phtml": "text.script.php",
        "pict": "image.pict",
        "pkg": "wrapper.installer-pkg",
        "pl": "text.script.perl",
        "playground": "file.playground",
        "plist": "text.plist",
        "pluginkit": "wrapper.app-extension",
        "pm": "text.script.perl",
        "png": "image.png",
        "pp": "sourcecode.pascal",
        "ppob": "archive.ppob",
        "proto": "sourcecode.protobuf",
        "py": "text.script.python",
        "qtz": "video.quartz-composer",
        "r": "sourcecode.rez",
        "rb": "text.script.ruby",
        "rbw": "text.script.ruby",
        "rcproject": "file.rcproject",
        "rcx": "compiled.rcx",
        "rez": "sourcecode.rez",
        "rhtml": "text.html.other",
        "rsrc": "archive.rsrc",
        "rtf": "text.rtf",
        "rtfd": "wrapper.rtfd",
        "s": "sourcecode.asm",
        "scnassets": "wrapper.scnassets",
        "scncache": "wrapper.scncache",
        "scnp": "file.scp",
        "scriptSuite": "text.plist.scriptSuite",
        "scriptTerminology": "text.plist.scriptTerminology",
        "sh": "text.script.sh",
        "shtml": "text.html.other",
        "sit": "archive.stuffit",
        "sks": "file.sks",
        "skybox": "file.skybox",
        "sqlite": "file",
        "storyboard": "file.storyboard",
        "storyboardc": "wrapper.storyboardc",
        "strings": "text.plist.strings",
        "stringsdict": "text.plist.stringsdict",
        "swift": "sourcecode.swift",
        "systemextension": "wrapper.system-extension",
        "tar": "archive.tar",
        "tbd": "sourcecode.text-based-dylib-definition",
        "tcc": "sourcecode.cpp.cpp",
        "text": "net.daringfireball.markdown",
        "tif": "image.tiff",
        "tiff": "image.tiff",
        "ttf": "file",
        "txt": "text",
        "uicatalog": "file.uicatalog",
        "usdz": "file.usdz",
        "vert": "sourcecode.glsl",
        "vertex": "sourcecode.glsl",
        "view": "archive.rsrc",
        "vs": "sourcecode.glsl",
        "vsh": "sourcecode.glsl",
        "war": "archive.war",
        "wav": "audio.wav",
        "worksheet": "text.script.worksheet",
        "xcassets": "folder.assetcatalog",
        "xcbuildrules": "text.plist.xcbuildrules",
        "xcclassmodel": "wrapper.xcclassmodel",
        "xcconfig": "text.xcconfig",
        "xcdatamodel": "wrapper.xcdatamodel",
        "xcdatamodeld": "wrapper.xcdatamodeld",
        "xcfilelist": "text.xcfilelist",
        "xcframework": "wrapper.xcframework",
        "xclangspec": "text.plist.xclangspec",
        "xcmappingmodel": "wrapper.xcmappingmodel",
        "xcode": "wrapper.pb-project",
        "xcodeproj": "wrapper.pb-project",
        "xconf": "text.xml",
        "xcplaygroundpage": "file.xcplaygroundpage",
        "xcspec": "text.plist.xcspec",
        "xcstickers": "folder.stickers",
        "xcsynspec": "text.plist.xcsynspec",
        "xctarget": "wrapper.pb-target",
        "xctest": "wrapper.cfbundle",
        "xctxtmacro": "text.plist.xctxtmacro",
        "xcworkspace": "wrapper.workspace",
        "xhtml": "text.xml",
        "xib": "file.xib",
        "xmap": "text.xml",
        "xml": "text.xml",
        "xpc": "wrapper.xpc-service",
        "xsl": "text.xml",
        "xslt": "text.xml",
        "xsp": "text.xml",
        "y": "sourcecode.yacc",
        "yaml": "text.yaml",
        "ym": "sourcecode.yacc",
        "yml": "text.yaml",
        "ymm": "sourcecode.yacc",
        "yp": "sourcecode.yacc",
        "ypp": "sourcecode.yacc",
        "yxx": "sourcecode.yacc",
        "zip": "archive.zip",
    ]

    /// Remote project reference dictionary keys.
    public struct ProjectReference {
        public static let projectReferenceKey = "ProjectRef"
        public static let productGroupKey = "ProductGroup"
    }
}
