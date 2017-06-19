//
//  AppDelegate+NI_Extension.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/19.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "AppDelegate+NI_Extension.h"
#import <objc/message.h>

static const void *KRotationType = @"rotationType";
@implementation AppDelegate (NI_Extension)

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (self.allowRotationType == AllowRotationMaskPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else if (self.allowRotationType == AllowRotationMaskAllButUpsideDown) {
        return  UIInterfaceOrientationMaskAllButUpsideDown;
    }else {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
}



- (void)setAllowRotationType:(AllowRotationType)allowRotationType {
    objc_setAssociatedObject(self, &KRotationType, @(allowRotationType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AllowRotationType)allowRotationType {
    return  [objc_getAssociatedObject(self, &KRotationType) integerValue];
}

@end
