//
//  AppDelegate+NI_Extension.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/19.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "AppDelegate.h"

typedef NS_ENUM(NSInteger , AllowRotationType){
    AllowRotationMaskPortrait = 0,          //竖屏
    AllowRotationMaskAllButUpsideDown,      //所有
    AllowRotationMaskLandscapeLeftOrRight,  //左右横屏
};

@interface AppDelegate (NI_Extension)
@property (nonatomic,assign) AllowRotationType allowRotationType;
@end
