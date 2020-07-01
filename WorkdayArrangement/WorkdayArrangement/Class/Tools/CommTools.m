//
//  CommTools.m
#import "CommTools.h"

@implementation CommTools


+ (NSString *)formatAddZero: (NSInteger) num {
    if (num > 10) {
        return [NSString stringWithFormat:@"%@",@(num)];
    } else {
        return [NSString stringWithFormat:@"0%@",@(num)];
    }
}

+ (UIColor *)colorTheme: (NSInteger) index {
    NSArray *arrHex = @[ UIColorFromRGB(0xFF8F6C), UIColorFromRGB(0x77CA75),
                         UIColorFromRGB(0x97BCFF), UIColorFromRGB(0x6C81FF),
                         UIColorFromRGB(0xC562FE), UIColorFromRGB(0xFFC66C),
                         UIColorFromRGB(0x7AE7BA), UIColorFromRGB(0xFF5A68)];
    NSInteger i = index%arrHex.count;
    return [arrHex objectAtIndex:i];
}

+ (NSString *)weekdayName: (NSString *) strDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:strDate];
    
    // set swedish locale
    //dateFormatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"];
    
    dateFormatter.dateFormat=@"EEEE";
    NSString *dayString = [[dateFormatter stringFromDate:date] capitalizedString];
    NSLog(@"day: %@", dayString);
    
    return dayString;
}

@end

