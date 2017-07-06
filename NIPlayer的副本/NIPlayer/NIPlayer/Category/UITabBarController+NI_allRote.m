//
//  UITabBarController+NI_allRote.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/8.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "UITabBarController+NI_allRote.h"

@implementation UITabBarController (NI_allRote)
- (BOOL)shouldAutorotate {
    return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.selectedViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return [self.selectedViewController preferredStatusBarStyle];
}
@end
