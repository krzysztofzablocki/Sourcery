import Foundation

/// Class that provides default build settings to be used in Xcode projects.
public class BuildSettingsProvider {
    /// Build settings variant.
    ///
    /// - all: all (debug & release).
    /// - debug: debug.
    /// - release: release.
    public enum Variant {
        case all, debug, release
    }

    /// Target platform.
    ///
    /// - iOS: iOS.
    /// - macOS: macOS.
    /// - tvOS: tvOS.
    /// - watchOS: watchOS.
    public enum Platform {
        case iOS, macOS, tvOS, watchOS
    }

    /// Target product type.
    ///
    /// - framework: framework.
    /// - staticLibrary: static library.
    /// - dynamicLibrary: dynamic library.
    /// - application: application.
    /// - bundle: bundle.
    public enum Product {
        case framework, staticLibrary, dynamicLibrary, application, bundle
    }

    /// Returns the default target build settings.
    ///
    /// - Parameters:
    ///   - variant: build settings variant.
    ///   - platform: target platform.
    ///   - product: target product.
    ///   - swift: true if the target contains Swift code.
    /// - Returns: build settings.
    // swiftlint:disable:next function_body_length
    public static func targetDefault(variant: Variant? = nil, platform: Platform?, product: Product?, swift: Bool? = nil) -> BuildSettings {
        var buildSettings: [String: Any] = [:]
        if let platform = platform, platform == .iOS {
            buildSettings["SDKROOT"] = "iphoneos"
            buildSettings["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
            buildSettings["CODE_SIGN_IDENTITY"] = "iPhone Developer"
        }
        if let platform = platform, platform == .macOS {
            buildSettings["SDKROOT"] = "macosx"
            buildSettings["CODE_SIGN_IDENTITY"] = "-"
            buildSettings["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/../Frameworks @loader_path/../Frameworks"
        }
        if let platform = platform, platform == .watchOS {
            buildSettings["SDKROOT"] = "watchos"
            buildSettings["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
        }
        if let platform = platform, platform == .tvOS {
            buildSettings["SDKROOT"] = "appletvos"
            buildSettings["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
        }
        if let platform = platform, let variant = variant, [.iOS, .watchOS, .tvOS].contains(platform), variant == .release {
            buildSettings["VALIDATE_PRODUCT"] = "YES"
        }
        if let variant = variant, let swift = swift, variant == .debug, swift == true {
            buildSettings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone"
            buildSettings["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = "DEBUG"
            buildSettings["SWIFT_COMPILATION_MODE"] = "singlefile"
        }
        if let variant = variant, let swift = swift, variant == .release, swift == true {
            buildSettings["SWIFT_OPTIMIZATION_LEVEL"] = "-Owholemodule"
            buildSettings["SWIFT_COMPILATION_MODE"] = "wholemodule"
        }
        if let product = product, product == .framework {
            buildSettings["CODE_SIGN_IDENTITY"] = ""
            buildSettings["CURRENT_PROJECT_VERSION"] = "1"
            buildSettings["DEFINES_MODULE"] = "YES"
            buildSettings["DYLIB_COMPATIBILITY_VERSION"] = "1"
            buildSettings["DYLIB_CURRENT_VERSION"] = "1"
            buildSettings["DYLIB_INSTALL_NAME_BASE"] = "@rpath"
            buildSettings["INSTALL_PATH"] = "$(LOCAL_LIBRARY_DIR)/Frameworks"
            buildSettings["PRODUCT_NAME"] = "$(TARGET_NAME:c99extidentifier)"
            buildSettings["SKIP_INSTALL"] = "YES"
            buildSettings["VERSION_INFO_PREFIX"] = ""
            buildSettings["VERSIONING_SYSTEM"] = "apple-generic"
        }
        if let platform = platform, let product = product, platform == .iOS, product == .framework {
            buildSettings["TARGETED_DEVICE_FAMILY"] = "1,2"
        }

        if let platform = platform, let product = product, platform == .macOS, product == .framework {
            buildSettings["COMBINE_HIDPI_IMAGES"] = "YES"
            buildSettings["FRAMEWORK_VERSION"] = "A"
        }
        if let platform = platform, let product = product, platform == .watchOS, product == .framework {
            buildSettings["APPLICATION_EXTENSION_API_ONLY"] = "YES"
            buildSettings["TARGETED_DEVICE_FAMILY"] = "4"
        }
        if let platform = platform, let product = product, platform == .tvOS, product == .framework {
            buildSettings["TARGETED_DEVICE_FAMILY"] = "3"
        }
        if let product = product, let swift = swift, product == .framework, swift == true {
            buildSettings["DEFINES_MODULE"] = "YES"
        }
        if let platform = platform, let product = product, platform == .iOS, product == .staticLibrary {
            buildSettings["OTHER_LDFLAGS"] = "-ObjC"
            buildSettings["SKIP_INSTALL"] = "YES"
            buildSettings["TARGETED_DEVICE_FAMILY"] = "1,2"
        }
        if let platform = platform, let product = product, platform == .watchOS, product == .staticLibrary {
            buildSettings["OTHER_LDFLAGS"] = "-ObjC"
            buildSettings["SKIP_INSTALL"] = "YES"
            buildSettings["TARGETED_DEVICE_FAMILY"] = "4"
        }
        if let platform = platform, let product = product, platform == .tvOS, product == .staticLibrary {
            buildSettings["OTHER_LDFLAGS"] = "-ObjC"
            buildSettings["SKIP_INSTALL"] = "YES"
            buildSettings["TARGETED_DEVICE_FAMILY"] = "3"
        }
        if let platform = platform, let product = product, platform == .macOS, product == .staticLibrary {
            buildSettings["EXECUTABLE_PREFIX"] = "lib"
            buildSettings["SKIP_INSTALL"] = "YES"
        }
        if let platform = platform, let product = product, platform == .macOS, product == .dynamicLibrary {
            buildSettings["DYLIB_COMPATIBILITY_VERSION"] = "1"
            buildSettings["DYLIB_CURRENT_VERSION"] = "1"
            buildSettings["EXECUTABLE_PREFIX"] = "lib"
            buildSettings["SKIP_INSTALL"] = "YES"
        }
        if let product = product, product == .application {
            buildSettings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"
        }
        if let platform = platform, let product = product, platform == .iOS, product == .application {
            buildSettings["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/Frameworks"
            buildSettings["TARGETED_DEVICE_FAMILY"] = "1,2"
        }
        if let platform = platform, let product = product, platform == .watchOS, product == .application {
            buildSettings["SKIP_INSTALL"] = "YES"
            buildSettings["TARGETED_DEVICE_FAMILY"] = "4"
        }
        if let platform = platform, let product = product, platform == .tvOS, product == .application {
            buildSettings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "App Icon & Top Shelf Image"
            buildSettings["ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME"] = "LaunchImage"
            buildSettings["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/Frameworks"
            buildSettings["TARGETED_DEVICE_FAMILY"] = "3"
        }
        if let platform = platform, let product = product, platform == .macOS, product == .application {
            buildSettings["COMBINE_HIDPI_IMAGES"] = "YES"
            buildSettings["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/../Frameworks"
        }
        if let platform = platform, let product = product, let swift = swift, platform == .watchOS, product == .application, swift == true {
            buildSettings["ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES"] = "YES"
        }
        if let product = product, product == .bundle {
            buildSettings["WRAPPER_EXTENSION"] = "bundle"
            buildSettings["SKIP_INSTALL"] = "YES"
        }
        if let product = product, let platform = platform, product == .bundle, platform == .macOS {
            buildSettings["COMBINE_HIDPI_IMAGES"] = "YES"
            buildSettings["INSTALL_PATH"] = "$(LOCAL_LIBRARY_DIR)/Bundles"
            buildSettings["SDKROOT"] = "macosx"
        }
        return buildSettings
    }

    /// Returns default build settings that Xcode sets in new projects.
    ///
    /// - Returns: build settings.
    public static func projectDefault(variant: Variant) -> BuildSettings {
        switch variant {
        case .all:
            return projectAll()
        case .debug:
            return projectDebug()
        case .release:
            return projectRelease()
        }
    }

    // MARK: - Private

    // swiftlint:disable:next function_body_length
    private static func projectAll() -> BuildSettings {
        return [
            "ALWAYS_SEARCH_USER_PATHS": "NO",
            "CLANG_ANALYZER_NONNULL": "YES",
            "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
            "CLANG_CXX_LANGUAGE_STANDARD": "gnu++14",
            "CLANG_CXX_LIBRARY": "libc++",
            "CLANG_ENABLE_MODULES": "YES",
            "CLANG_ENABLE_OBJC_ARC": "YES",
            "CLANG_ENABLE_OBJC_WEAK": "YES",
            "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
            "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
            "CLANG_WARN_BOOL_CONVERSION": "YES",
            "CLANG_WARN_COMMA": "YES",
            "CLANG_WARN_CONSTANT_CONVERSION": "YES",
            "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
            "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
            "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
            "CLANG_WARN_EMPTY_BODY": "YES",
            "CLANG_WARN_ENUM_CONVERSION": "YES",
            "CLANG_WARN_INFINITE_RECURSION": "YES",
            "CLANG_WARN_INT_CONVERSION": "YES",
            "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
            "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
            "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
            "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
            "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
            "CLANG_WARN_STRICT_PROTOTYPES": "YES",
            "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
            "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
            "CLANG_WARN_UNREACHABLE_CODE": "YES",
            "COPY_PHASE_STRIP": "NO",
            "ENABLE_STRICT_OBJC_MSGSEND": "YES",
            "GCC_C_LANGUAGE_STANDARD": "gnu11",
            "GCC_NO_COMMON_BLOCKS": "YES",
            "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
            "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
            "GCC_WARN_UNDECLARED_SELECTOR": "YES",
            "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
            "GCC_WARN_UNUSED_FUNCTION": "YES",
            "GCC_WARN_UNUSED_VARIABLE": "YES",
            "PRODUCT_NAME": "$(TARGET_NAME)",
        ]
    }

    private static func projectDebug() -> BuildSettings {
        return [
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "ENABLE_TESTABILITY": "YES",
            "GCC_DYNAMIC_NO_PIC": "NO",
            "GCC_OPTIMIZATION_LEVEL": "0",
            "GCC_PREPROCESSOR_DEFINITIONS": ["DEBUG=1", "$(inherited)"],
            "MTL_ENABLE_DEBUG_INFO": "YES",
            "ONLY_ACTIVE_ARCH": "YES",
        ]
    }

    private static func projectRelease() -> BuildSettings {
        return [
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "ENABLE_NS_ASSERTIONS": "NO",
            "MTL_ENABLE_DEBUG_INFO": "NO",
        ]
    }
}
