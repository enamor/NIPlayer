//
//  UINavigationController+NI_allowRote.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/8.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "UINavigationController+NI_allowRote.h"

@implementation UINavigationController (NI_allowRote)

- (BOOL)shouldAutorotate {
    return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.visibleViewController supportedInterfaceOrientations];
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return [self.visibleViewController preferredStatusBarStyle];
}


@end
