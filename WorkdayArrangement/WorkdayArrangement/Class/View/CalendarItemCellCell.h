//
//  CalendarItemCellCell.h


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalendarItemCellCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *viewBg;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@end

NS_ASSUME_NONNULL_END
