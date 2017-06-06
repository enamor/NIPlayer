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

@end
@implementation NIPlayer

//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        APP_DELEGATE.allowRotation = 1;
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
    [self fullScreen:nil];
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
    __weak typeof(self) weakSelf = self;
    [self.avPlayer playWithUrl:url statusBlock:^(NIAVPlayerStatus status) {
        switch (status) {
            case NIAVPlayerStatusLoading: {
                
                break;
            }
            case NIAVPlayerStatusReadyToPlay: {

                
                break;
            }
            case NIAVPlayerStatusPlayEnd: {
                self.playerControl.playButton.selected = NO;
                [self.avPlayer pause];
                break;
            }
            case NIAVPlayerStatusCacheData: {
                
                break;
            }
            case NIAVPlayerStatusCacheEnd: {
                
                break;
            }
            case NIAVPlayerStatusPlayStop: {
                [self.avPlayer pause];
                break;
            }
            case NIAVPlayerStatusItemFailed: {
                
                break;
            }
            case NIAVPlayerStatusEnterBack: {
                APP_DELEGATE.allowRotation = 10;
                break;
            }
                
            case NIAVPlayerStatusBecomeActive: {
                APP_DELEGATE.allowRotation = 1;
                break;
            }
                
            default:
                break;
        }
        
    }];
    
}

#pragma mark ------ IBAction


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Private
- (void)p_initUI {
    self.avPlayer = [[NIAVPlayer alloc] init];
    [self addSubview:_avPlayer];
    
    CGFloat wid = [UIScreen mainScreen].bounds.size.width;
    CGFloat hei = [UIScreen mainScreen].bounds.size.height;
    CGFloat rate = wid < hei ? (wid/hei) : (hei/wid);

    
    [self.avPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
//        make.top.equalTo(self);
//        make.left.right.equalTo(self);
//        make.height.mas_equalTo(self.avPlayer.mas_width).multipliedBy(rate);
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
        self.playerControl.isFullScreen = _isFullScreen;
    } else {
        self.isFullScreen = NO;
        self.playerControl.isFullScreen = _isFullScreen;
    }
    
}

#pragma mark - Public
- (void)fullScreen:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if(sender.selected) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        
    } else {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        
    }
    [[[self getCurrentViewController] class] attemptRotationToDeviceOrientation];
    
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

@end
