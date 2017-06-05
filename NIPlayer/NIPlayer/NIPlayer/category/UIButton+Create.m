//
//  UIButton+Create.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "UIButton+Create.h"

@implementation UIButton (Create)
+ (UIButton *)buttonWithTitle:(NSString *)title
               fontSize:(CGFloat)fontSize
              textColor:(UIColor *)color {
    return  [self buttonWithTitle:title fontSize:fontSize textColor:color image:nil selectedImage:nil];
}

+ (UIButton *)buttonWithTitle:(NSString *)title
               fontSize:(CGFloat)fontSize
              textColor:(UIColor *)color
                  image:(NSString *)img {
    return  [self buttonWithTitle:title fontSize:fontSize textColor:color image:img selectedImage:nil];
}

+ (UIButton *)buttonWithTitle:(NSString *)title
               fontSize:(CGFloat)fontSize
              textColor:(UIColor *)color
                  image:(NSString *)img
          selectedImage:(NSString *)selImg {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    btn.titleLabel.textColor = color;
    [btn setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selImg] forState:UIControlStateSelected];
    [btn sizeToFit];
    return btn;
    
}

+ (UIButton *)buttonWithImage:(NSString *)img {
    return [self buttonWithImage:img selectedImage:nil];
}

+ (UIButton *)buttonWithImage:(NSString *)img
          selectedImage:(NSString *)selImg {
    return [self buttonWithTitle:nil fontSize:0 textColor:nil image:img selectedImage:selImg];
}

+ (UIButton *)buttonWithBgImage:(NSString *)bgImg {
    return [self buttonWithBgImage:bgImg bgSelectedImage:nil];
}

+ (UIButton *)buttonWithBgImage:(NSString *)bgImg
          bgSelectedImage:(NSString *)bgSelImg {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:bgImg] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:bgSelImg] forState:UIControlStateSelected];
    [btn sizeToFit];
    return btn;
}

- (void)setImage:(UIImage *)image {
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image selectedImage:(UIImage *)selImg {
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:selImg forState:UIControlStateSelected];
}

- (void)setImage:(UIImage *)image disabledImage:(UIImage *)disImg {
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:disImg forState:UIControlStateDisabled];
}
@end
