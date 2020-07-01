//
//  CommTools.h


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommTools : NSObject


+ (NSString *)formatAddZero: (NSInteger) num;

+ (UIColor *)colorTheme: (NSInteger) index;

+ (NSString *)weekdayName: (NSString *) strDate ;


@end

NS_ASSUME_NONNULL_END
