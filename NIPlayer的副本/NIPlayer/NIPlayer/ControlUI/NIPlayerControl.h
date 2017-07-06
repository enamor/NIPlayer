//
//  NIPlayerControl.h
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIPlayerSlider.h"
#import "NIPlayerControlProtocol.h"


@interface NIPlayerControl : UIView
@property (nonatomic, strong) UIButton *fullScreenBtn;

@property (nonatomic, strong) NIPlayerSlider *progressSlider;

@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL isFinishedSeek;

@property (nonatomic, weak) id<NIPlayerControlDelegate> controlDelegate;

- (void)seekTo:(double)time totalTime:(double)totalTime;

//这两个方法需要结合使用
- (void)seekPipTo:(double)time totalTime:(double)totalTime;
- (void)seekToImage:(UIImage *)image;

- (void)showOrHidenBar;

- (void)startLoading;
- (void)endLoading;

- (void)playError;

- (void)reset;

@end
