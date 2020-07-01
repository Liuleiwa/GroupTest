//
//  RMDayDuty.h


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMDayDuty : RLMObject

@property NSInteger day;
@property NSString *name;
@property NSString   *yearMonth;
@property NSString   *pKeyDate;

@end

NS_ASSUME_NONNULL_END
