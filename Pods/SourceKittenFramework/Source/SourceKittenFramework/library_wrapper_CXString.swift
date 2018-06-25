#if !os(Linux)
#if SWIFT_PACKAGE
import Clang_C
#endif
private let library = toolchainLoader.load(path: "libclang.dylib")
internal let clang_getCString: @convention(c) (CXString) -> (UnsafePointer<Int8>?) = library.load(symbol: "clang_getCString")
internal let clang_disposeString: @convention(c) (CXString) -> () = library.load(symbol: "clang_disposeString")
internal let clang_disposeStringSet: @convention(c) (UnsafeMutablePointer<CXStringSet>?) -> () = library.load(symbol: "clang_disposeStringSet")
#endif
