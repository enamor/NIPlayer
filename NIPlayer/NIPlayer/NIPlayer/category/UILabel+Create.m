//
//  UILabel+Create.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "UILabel+Create.h"

@implementation UILabel (Create)
+ (UILabel *)labelWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.text = text;
    [label sizeToFit];
    return label;
}

+ (UILabel *)labelWithFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor {
    return [self labelWithText:nil fontSize:fontSize textColor:textColor];
}
@end
