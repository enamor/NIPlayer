//
//  AppDelegate.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , AllowRotationType){
    AllowRotationMaskPortrait = 0,          //竖屏
    AllowRotationMaskAllButUpsideDown,      //所有
    AllowRotationMaskLandscapeLeftOrRight,  //左右横屏
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,assign) AllowRotationType allowRotationType;

@end

