//
//  CalendarDayCell.h


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalendarDayCell : UICollectionViewCell

@property (strong, nonatomic) UIView *viewBg;
@property (strong, nonatomic) UILabel *labelDay;
@property (strong, nonatomic) UILabel *labelName;

@end

NS_ASSUME_NONNULL_END
