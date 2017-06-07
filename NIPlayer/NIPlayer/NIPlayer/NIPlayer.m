//
//  NIPlayer.m
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NIPlayer.h"
#import <Masonry.h>
#import "NIAVPlayer.h"
#import "NIPlayerControl.h"
#import "NIPlayerMacro.h"


@interface NIPlayer ()<NIPlayerControlDelegate>
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) NIAVPlayer *avPlayer;
@property (nonatomic, strong) NIPlayerControl *playerControl;

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, assign) BOOL isPlayOnView;

@end
@implementation NIPlayer

//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        APP_DELEGATE.allowRotationType = AllowRotationMaskAllButUpsideDown;
        [self p_initUI];
        [self p_initObserver];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Protocol
- (void)playerControl:(UIView *)control backAction:(UIButton *)sender {
    if (_isFullScreen) {
        [self fullScreen:_playerControl.fullScreenBtn];
    }
    
}
- (void)playerControl:(UIView *)control fullScreenAction:(UIButton *)sender {
    [self fullScreen:sender];
}
- (void)playerControl:(UIView *)control playAction:(UIButton *)sender {
    
    if (self.avPlayer.isPlay) {
        [self.avPlayer pause];
        sender.selected = YES;
    } else {
        [self.avPlayer play];
        sender.selected = NO;
    }
    
}
- (void)playerControl:(UIView *)control seekAction:(UISlider *)sender {
    NSTimeInterval seekTime = sender.value * self.avPlayer.totalTime;
    [self.avPlayer seekTo:seekTime];
}
#pragma mark ------ UITextFieldDelegate
#pragma mark ------ UITableViewDataSource
#pragma mark ------ UITableViewDelegate
#pragma mark ------ UIScrollViewDelegate



//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Override

#pragma mark ------ Public
- (void)playWithUrl:(NSString *)url {
    [self.avPlayer playWithUrl:url];
    
}

- (void)playWithUrl:(NSString *)url onView:(UIView *)view {
    self.superView = view;
    self.isPlayOnView = YES;
    [self playWithUrl:url];
}

- (void)play {
    [self.avPlayer play];
}

- (void)pause {
    [self.avPlayer pause];
}

#pragma mark ------ IBAction


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Private
- (void)p_initUI {
    self.backgroundColor = [UIColor blackColor];
    self.avPlayer = [[NIAVPlayer alloc] init];
    [self addSubview:_avPlayer];
    
    [self.avPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.playerControl = [[NIPlayerControl alloc] init];
    _playerControl.controlDelegate = self;
    [_avPlayer addSubview:_playerControl];
    [self.playerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.avPlayer);
    }];
}

- (void)p_initDatas {
    
}

- (void)p_initObserver {
    //监听屏幕方向
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initScreenOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    //监听播放进度、缓冲进度
    __weak typeof(self) weakSelf = self;
    self.avPlayer.progressBlock = ^(CGFloat value, NIAVPlayerProgressType type) {
        if (type == NIAVPlayerProgressCache) {
            weakSelf.playerControl.progressSlider.cacheValue = value;
        } else {
            weakSelf.playerControl.progressSlider.value = value;
        }
    };
    
    //监听播放状态
    self.avPlayer.statusBlock = ^(NIAVPlayerStatus status) {
        switch (status) {
            case NIAVPlayerStatusLoading: {
                
                break;
            }
            case NIAVPlayerStatusReadyToPlay: {
                
                
                break;
            }
            case NIAVPlayerStatusPlayEnd: {
                weakSelf.playerControl.playButton.selected = NO;
                [weakSelf.avPlayer pause];
                break;
            }
            case NIAVPlayerStatusCacheData: {
                
                break;
            }
            case NIAVPlayerStatusCacheEnd: {
                
                break;
            }
            case NIAVPlayerStatusPlayStop: {
                weakSelf.playerControl.playButton.selected = NO;
                [weakSelf.avPlayer pause];
                break;
            }
            case NIAVPlayerStatusItemFailed: {
                weakSelf.playerControl.playButton.selected = NO;
                break;
            }
            case NIAVPlayerStatusEnterBack: {
                if (weakSelf.isFullScreen) {
                    APP_DELEGATE.allowRotationType = AllowRotationMaskLandscapeLeftOrRight;
                }
                break;
            }
                
            case NIAVPlayerStatusBecomeActive: {
                APP_DELEGATE.allowRotationType = AllowRotationMaskAllButUpsideDown;
                break;
            }
                
            default:
                break;
        }

    };
}

- (void)p_removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark 监听屏幕旋转
- (void)p_initScreenOrientationChanged:(id)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight ||
        orientation ==UIInterfaceOrientationLandscapeLeft) {
        self.isFullScreen = YES;
        
    } else {
        self.isFullScreen = NO;
    }
    
}

#pragma mark - Public
- (void)fullScreen:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (_isPlayOnView) {
        if (sender.selected) {
            [self removeFromSuperview];
            
            CGFloat height = [[UIScreen mainScreen] bounds].size.width;
            CGFloat width = [[UIScreen mainScreen] bounds].size.height;
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [UIView animateWithDuration:0.3f animations:^{
                [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo((height - width) / 2);
                    make.top.mas_equalTo((width - height) / 2);
                    make.width.mas_equalTo(width);
                    make.height.mas_equalTo(height);
                }];
                [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            } completion:^(BOOL finished) {
                self.isFullScreen = YES;
            }];
        } else {
            [self removeFromSuperview];
            [self.superView addSubview:self];
            [UIView animateWithDuration:0.3f animations:^{
                [self setTransform:CGAffineTransformIdentity];
                
                [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.superView);
                }];
                
            } completion:^(BOOL finished) {
                self.isFullScreen = NO;
            }];
        }
    } else {
        
        if(sender.selected) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
            self.isFullScreen = YES;
            
        } else {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
            self.isFullScreen = NO;
        }
        [[[self getCurrentViewController] class] attemptRotationToDeviceOrientation];
    }
    
    
    
}


/** 获取当前View的控制器对象 */
-(UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ getter setter
- (void)setSuperView:(UIView *)superView {
    _superView = superView;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superView);
    }];
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    self.playerControl.isFullScreen = _isFullScreen;
}
@end
