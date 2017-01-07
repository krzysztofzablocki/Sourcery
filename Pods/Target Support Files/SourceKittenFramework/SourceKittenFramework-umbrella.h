#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BuildSystem.h"
#import "CXCompilationDatabase.h"
#import "CXErrorCode.h"
#import "CXString.h"
#import "Documentation.h"
#import "Index.h"
#import "Platform.h"
#import "sourcekitd.h"

FOUNDATION_EXPORT double SourceKittenFrameworkVersionNumber;
FOUNDATION_EXPORT const unsigned char SourceKittenFrameworkVersionString[];

