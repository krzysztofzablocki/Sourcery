#import "KioskDateFormatter.h"
@import ISO8601DateFormatter;

@implementation KioskDateFormatter

+ (NSDate *)fromString:(NSString *)string {
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    return [formatter dateFromString:string];
}

@end
