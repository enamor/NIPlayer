//
//  NSDate+NI_time.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/8.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NSDate+NI_time.h"

@implementation NSDate (NI_time)
+ (NSString *)hourTime:(double)second {
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [dateFormatter stringFromDate:d];
    return showtimeNew;
}
@end
