//
//  DutyListCell.h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DutyListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *viewBg;
@property (weak, nonatomic) IBOutlet UILabel *labelDay;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewRight;

@property (weak, nonatomic) IBOutlet UILabel *labelWeekday;


@end

NS_ASSUME_NONNULL_END
