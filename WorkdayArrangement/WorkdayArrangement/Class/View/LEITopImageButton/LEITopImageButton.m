//
//  LEITopImageButton.m


#import "LEITopImageButton.h"

@implementation LEITopImageButton


-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor redColor];
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleX = 0;
//    CGFloat titleY = contentRect.size.height * 0.7;
    CGFloat titleW = contentRect.size.width;
//    CGFloat titleH = contentRect.size.height - titleY;
    return CGRectMake(titleX, 30, titleW, 17);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{

    CGFloat imageH = 25;
        CGFloat titleW = contentRect.size.width;
    return CGRectMake(0, 10, titleW, imageH);
}

@end
