//
//  NIPlayer.m
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NIPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

#import <Masonry.h>

#import "UINavigationController+NI_allowRote.h"
#import "UITabBarController+NI_allRote.h"
#import "UIView+NI_superVC.h"

#import "NIAVPlayer.h"
#import "NIPlayerControl.h"
#import "NIPlayerMacro.h"
#import "NIBrightnessView.h"

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};


@interface NIPlayer ()<NIPlayerControlDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) NIAVPlayer *avPlayer;
@property (nonatomic, strong) NIPlayerControl *playerControl;

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, assign) BOOL isPlayOnView;

@property (nonatomic, assign) UIStatusBarStyle barStyle;


/** 用来保存快进的总时长 */
@property (nonatomic, assign) double                sumTime;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection           panDirection;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                   isVolume;
@property (nonatomic, strong) UISlider               *volumeViewSlider;

@end
@implementation NIPlayer

//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.barStyle = APP.statusBarStyle;
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
    } else {
        if (self.getCurrentVC.presentingViewController) {
            [self.getCurrentVC dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.getCurrentNavVC popViewControllerAnimated:YES];
        }
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

- (void)playerControl:(UIView *)control sliderValueChangedAction:(UISlider *)sender {
    [self.avPlayer getCImage:sender.value * self.avPlayer.totalTime block:^(UIImage *image) {
        [self.playerControl seekTo:sender.value * self.avPlayer.totalTime totalTime:self.avPlayer.totalTime image:image];
    }];
    
    [self.avPlayer startToSeek];
}
#pragma mark ------ UITextFieldDelegate
#pragma mark ------ UITableViewDataSource
#pragma mark ------ UITableViewDelegate
#pragma mark ------ UIScrollViewDelegate



//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Override

#pragma mark ------ Public
- (void)playWithUrl:(NSString *)url {
    [self.playerControl reset];
    APP_DELEGATE.allowRotationType = AllowRotationMaskAllButUpsideDown;
    [self.avPlayer playWithUrl:url];
    [self p_configureVolume];
}

- (void)playWithUrl:(NSString *)url onView:(UIView *)view {
    [self.playerControl reset];
    self.superView = view;
    self.isPlayOnView = YES;
    APP_DELEGATE.allowRotationType = AllowRotationMaskPortrait;
    [self.avPlayer playWithUrl:url];
    [self p_configureVolume];
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
    self.avPlayer = [[NIAVPlayer alloc] init];
    [self addSubview:_avPlayer];
    
    [self.avPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.playerControl = [[NIPlayerControl alloc] init];
    _playerControl.controlDelegate = self;
    [self addSubview:_playerControl];
    [self.playerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.avPlayer);
    }];
}

- (void)p_initDatas {
    
}

- (void)p_initObserver {
    //监听屏幕方向
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initScreenOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initAudioVolumeObserver:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];

    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initaudioRouteChangeObserver:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    //监听播放进度、缓冲进度
    __weak typeof(self) weakSelf = self;
    self.avPlayer.progressBlock = ^(CGFloat value, NIAVPlayerProgressType type) {
        if (type == NIAVPlayerProgressCache) {
            weakSelf.playerControl.progressSlider.cacheValue = value;
        
        } else {
            [weakSelf.playerControl seekTo:weakSelf.avPlayer.currentTime totalTime:weakSelf.avPlayer.totalTime];
        }
    };
    
    //监听播放状态
    self.avPlayer.statusBlock = ^(NIAVPlayerStatus status) {
        switch (status) {
            case NIAVPlayerStatusLoading: {
                
                break;
            }
            case NIAVPlayerStatusReadyToPlay: {
                weakSelf.playerControl.playButton.selected = NO;
                [weakSelf addTap];
                break;
            }
            case NIAVPlayerStatusPlayEnd: {
                weakSelf.playerControl.playButton.selected = YES;
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
                weakSelf.playerControl.playButton.selected = YES;
                [weakSelf.avPlayer pause];
                break;
            }
            case NIAVPlayerStatusItemFailed: {
                weakSelf.playerControl.playButton.selected = YES;
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
        APP.statusBarStyle = UIStatusBarStyleLightContent;
        
    } else {
        self.isFullScreen = NO;
        APP.statusBarStyle = _barStyle;
    }
    
}

//监听系统音量改变
- (void)p_initAudioVolumeObserver:(id)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    self.volumeViewSlider.value = volume;
    
}

//耳机插入拔出
- (void)p_initaudioRouteChangeObserver:(id)notification {
    NSDictionary *interuptionDict = [notification userInfo];
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            // 耳机拔掉
            [self play];
            break;
        }
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}


/**
 *  获取系统音量
 */
- (void)p_configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }

    
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
            [[NIBrightnessView sharedInstance] show];
            [UIView animateWithDuration:0.3f animations:^{
                [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                
            } completion:^(BOOL finished) {
                self.isFullScreen = YES;
            }];
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo((height - width) / 2);
                make.top.mas_equalTo((width - height) / 2);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(height);
            }];
            APP.statusBarOrientation = UIInterfaceOrientationLandscapeRight;
            APP.statusBarStyle = UIStatusBarStyleLightContent;
            APP.statusBarHidden = NO;
        } else {
            [self removeFromSuperview];
            [[NIBrightnessView sharedInstance] removeFromSuperview];
            
            [self.superView addSubview:self];
            [UIView animateWithDuration:0.3f animations:^{
                [self setTransform:CGAffineTransformIdentity];
                
            } completion:^(BOOL finished) {
                self.isFullScreen = NO;
            }];
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.superView);
            }];
            APP.statusBarOrientation = UIInterfaceOrientationPortrait;
            APP.statusBarStyle = _barStyle;
            APP.statusBarHidden = NO;
        }
    } else {
        
        if(sender.selected) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
            self.isFullScreen = YES;
            [[NIBrightnessView sharedInstance] show];
            APP.statusBarStyle = UIStatusBarStyleLightContent;
            
        } else {
            [[NIBrightnessView sharedInstance] removeFromSuperview];
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
            APP.statusBarStyle = _barStyle;
            self.isFullScreen = NO;
        }
        [[[self getCurrentVC] class] attemptRotationToDeviceOrientation];
    }
    
    
}



#pragma mark - UIPanGestureRecognizer手势方法

/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan {
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { //水平移动
                // 取消隐藏
                self.panDirection = PanDirectionHorizontalMoved;
                // 给sumTime初值
                self.sumTime = self.avPlayer.currentTime;
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self.avPlayer seekTo:self.sumTime];
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)addTap {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    panRecognizer.delegate = self;
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelaysTouchesBegan:YES];
    [panRecognizer setDelaysTouchesEnded:YES];
    [panRecognizer setCancelsTouchesInView:YES];
    [self addGestureRecognizer:panRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
//    if (gestureRecognizer == self.shrinkPanGesture && self.isCellVideo) {
//        if (!self.isBottomVideo || self.isFullScreen) {
//            return NO;
//        }
//    }
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && gestureRecognizer != self.shrinkPanGesture) {
//        if ((self.isCellVideo && !self.isFullScreen) || self.playDidEnd || self.isLocked){
//            return NO;
//        }
//    }
//    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//        if (self.isBottomVideo && !self.isFullScreen) {
//            return NO;
//        }
//    }
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    
    return YES;
}

- (void)horizontalMoved:(CGFloat)value {
    
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    
    // 需要限定sumTime的范围
    double totalSeconds = self.avPlayer.totalTime;
    if (self.sumTime > totalSeconds) { self.sumTime = totalSeconds;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    
    BOOL style = false;
    if (value > 0) { style = YES; }
    if (value < 0) { style = NO; }
    if (value == 0) { return; }
    
    [self.playerControl seekTo:self.sumTime totalTime:totalSeconds];
    [self.avPlayer startToSeek];
    
}

- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
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
