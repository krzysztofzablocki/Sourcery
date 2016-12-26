#import <Foundation/Foundation.h>
#import <Stripe/Stripe.h>

@interface STPCard (Validation)

+ (BOOL)validateCardNumber:(NSString *)cardNumber;

@end
