//
//  CalendarDayModel.h


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalendarDayModel : NSObject

@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) NSUInteger month;
@property (nonatomic, assign) NSUInteger day;
@property (nonatomic, assign) NSUInteger weekday;

@property (nonatomic, strong) NSString *strYearMonth;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *weekdayName;

@end

NS_ASSUME_NONNULL_END
