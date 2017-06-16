//
//  TabBarController.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/16.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "TabBarController.h"
#import "BaseNavController.h"
#import "HomeViewController.h"
#import "VideoViewController.h"

#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"

@interface TabBarController ()

@end

@implementation TabBarController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_setupSubviews];
    
    //背景颜色
    [self.tabBar setBarTintColor:[UIColor whiteColor]];
    //取消tabBar的透明效果。
    self.tabBar.translucent = NO;
    
    //去处顶部分割线
    [self.tabBar setShadowImage:[UIImage new]];
    [self.tabBar setBackgroundImage:[UIImage new]];
    
    //阴影
//    self.tabBar.layer.shadowOpacity = 0.15;
    
    //改变tabbar 线条颜色
//    CGRect rect = CGRectMake(0, 0, self.tabBar.frame.size.width, 1);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context,[UIColor redColor].CGColor);
//    CGContextFillRect(context, rect);
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [self.tabBar setShadowImage:img];
//    [self.tabBar setBackgroundImage:[[UIImage alloc]init]];
    
}

- (void)p_setupSubviews {
    NSArray *childItemsArray = @[
                                 @{kClassKey  : @"HomeViewController",
                                   kTitleKey  : @"首页",
                                   kImgKey    : @"tabbar_mainframe",
                                   kSelImgKey : @"tabbar_mainframeHL"},
                                 
                                 @{kClassKey  : @"VideoViewController",
                                   kTitleKey  : @"视频",
                                   kImgKey    : @"tabbar_contacts",
                                   kSelImgKey : @"tabbar_contactsHL"} ];
    
    
    [childItemsArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = [NSClassFromString(dict[kClassKey]) new];
        vc.title = dict[kTitleKey];
        BaseNavController *nav = [[BaseNavController alloc] initWithRootViewController:vc];
        UITabBarItem *item = nav.tabBarItem;
        item.title = dict[kTitleKey];
        item.image = [[UIImage imageNamed:dict[kImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[UIImage imageNamed:dict[kSelImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //title间距
        item.titlePositionAdjustment = UIOffsetMake(0, -2);
        item.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        
        //默认状态下文字颜色
        //        [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kThemeColor} forState:UIControlStateNormal];
        //选中状态下文字颜色
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor orangeColor]} forState:UIControlStateSelected];
        [self addChildViewController:nav];
        
    }];
    self.selectedIndex = 0;
    
}
@end
