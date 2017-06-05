//
//  UILabel+Create.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Create)
+ (UILabel *)labelWithFontSize:(CGFloat)fontSize
                      textColor:(UIColor *)textColor ;

+ (UILabel *)labelWithText:(NSString *)text
                   fontSize:(CGFloat)fontSize
                  textColor:(UIColor *)textColor ;
@end
