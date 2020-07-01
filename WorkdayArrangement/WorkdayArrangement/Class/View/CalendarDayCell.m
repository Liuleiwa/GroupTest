//
//  CalendarDayCell.m


#import "CalendarDayCell.h"

@implementation CalendarDayCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self = [self sharedInit];
    }
    return self;
}

- (id)sharedInit {
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat widthDay = W(self);
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(5, 0, widthDay-10, widthDay-10)];
    viewBg.backgroundColor = kColorGrayEF;
    [viewBg.layer setCornerRadius:6];
    [self addSubview:viewBg];
    
    UILabel *labelDay = [[UILabel alloc] initWithFrame:CGRectMake(6, 4, widthDay-10, 20)];
    //labelDay.text = @"4";
    labelDay.font = [UIFont systemFontOfSize:14];
    labelDay.textColor = kColor999;
    [viewBg addSubview:labelDay];
    
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(6, H(viewBg)-24, widthDay-10, 20)];
    labelName.text = @"Jennifer";
    labelName.font = [UIFont systemFontOfSize:11];
    labelName.textColor = kColor999;
    [viewBg addSubview:labelName];
    
    return self;
}


@end
