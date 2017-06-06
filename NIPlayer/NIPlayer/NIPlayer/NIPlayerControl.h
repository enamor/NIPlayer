//
//  NIPlayerControl.h
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIPlayerSlider.h"
@protocol  NIPlayerControlDelegate<NSObject>
- (void)playerControl:(UIView *)control backAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control fullScreenAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control playAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control nextAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control seekAction:(UISlider *)sender ;

@end

@interface NIPlayerControl : UIView
@property (nonatomic, strong) UIButton *fullScreenBtn;
@property (nonatomic, readonly, strong) UIButton *playButton;
@property (nonatomic, strong) NIPlayerSlider *progressSlider;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, weak) id<NIPlayerControlDelegate> controlDelegate;


@end
