//
//  UIView+NI_superVC.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/9.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "UIView+NI_superVC.h"

@implementation UIView (NI_superVC)
//获取当前控制器
- (UIViewController *)getCurrentVC {
    UIResponder *next = self.nextResponder;
    do {
        //判断响应者是否为视图控制器
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = next.nextResponder;
        
    } while (next != nil);
    return nil;
}

//获取导航控制器
- (UINavigationController *)getCurrentNavVC {
    UIResponder *next = self.nextResponder;
    do {
        //判断响应者是否为视图控制器
        if ([next isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)next;
        }
        next = next.nextResponder;
        
    } while (next != nil);
    return nil;
}
@end
