#import "STPCard+Validation.h"

@implementation STPCard (Validation)

+ (BOOL)validateCardNumber:(NSString *)cardNumber {
    STPCard *card = [[STPCard alloc] init];
    card.number = cardNumber;

    __autoreleasing NSString *cardNumberCopy = [cardNumber copy];

    return [card validateNumber:&cardNumberCopy error:nil];
}

@end
