//
//  NIPlayer.h
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIPlayer : UIView
- (void)playWithUrl:(NSString *)url;

- (void)playWithUrl:(NSString *)url onView:(UIView *)view;

- (void)play;
- (void)pause;
@end
