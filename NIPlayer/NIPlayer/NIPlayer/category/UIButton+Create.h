//
//  UIButton+Create.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Create)
+ (UIButton *)buttonWithTitle:(NSString *)title
               fontSize:(CGFloat)fontSize
              textColor:(UIColor *)color;

+ (UIButton *)buttonWithTitle:(NSString *)title
               fontSize:(CGFloat)fontSize
              textColor:(UIColor *)color
                  image:(NSString *)img;

+ (UIButton *)buttonWithTitle:(NSString *)title
               fontSize:(CGFloat)fontSize
              textColor:(UIColor *)color
                  image:(NSString *)img
          selectedImage:(NSString *)selImg;

+ (UIButton *)buttonWithImage:(NSString *)img;

+ (UIButton *)buttonWithImage:(NSString *)img
          selectedImage:(NSString *)selImg;

+ (UIButton *)buttonWithBgImage:(NSString *)bgImg;

+ (UIButton *)buttonWithBgImage:(NSString *)bgImg
          bgSelectedImage:(NSString *)bgSelImg;


- (void)setImage:(UIImage *)image;
- (void)setImage:(UIImage *)image selectedImage:(UIImage *)selImg;
- (void)setImage:(UIImage *)image disabledImage:(UIImage *)disImg;
@end
