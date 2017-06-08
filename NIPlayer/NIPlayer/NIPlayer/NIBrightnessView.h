//
//  NIBrightnessView.h
//  NIPlayer
//
//  Created by zhouen on 17/1/4.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIBrightnessView : UIView

/** 调用单例记录播放状态是否锁定屏幕方向*/
@property (nonatomic, assign) BOOL     isLockScreen;
/** 是否允许横屏,来控制只有竖屏的状态*/
@property (nonatomic, assign) BOOL     isAllowLandscape;

+ (instancetype)sharedInstance;

- (void)show;

@end
