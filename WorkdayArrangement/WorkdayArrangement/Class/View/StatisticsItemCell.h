//
//  StatisticsItemCell.h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatisticsItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *viewDot;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;


@end

NS_ASSUME_NONNULL_END
