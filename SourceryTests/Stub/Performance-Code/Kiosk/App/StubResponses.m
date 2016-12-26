#import "StubResponses.h"

#define STUB_RESPONSES YES

// We're inferring if you have access to the private Artsy fonts, then you have access to our API.
#if __has_include(<Artsy_UIFonts/UIFont+ArtsyFonts.h>)
#undef STUB_RESPONSES
#define STUB_RESPONSES NO
#endif

@implementation StubResponses

+ (BOOL)stubResponses {
    return STUB_RESPONSES;
}

@end
