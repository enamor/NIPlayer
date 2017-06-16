//
//  NIPlayer.h
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIPlayer : UIView
+ (NIPlayer *_Nonnull)sharedPlayer;

- (void)playWithUrl:(NSString *_Nonnull)url onView:(UIView *_Nonnull)view;

- (void)play;
- (void)pause;

- (void)releasePlayer;
@end
