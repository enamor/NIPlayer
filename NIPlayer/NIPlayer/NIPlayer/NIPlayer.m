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
#import "AppDelegate+NI_Extension.h"
#import "UIView+NI_superVC.h"

#import "NIAVPlayer.h"
#import "NIPlayerControl.h"
#import "NIPlayerMacro.h"
#import "NIBrightnessView.h"

//手指滑动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};



@interface NIPlayer ()<NIPlayerControlDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) NIAVPlayer            *avPlayer;         //AVPlayer播放器
@property (nonatomic, strong) NIPlayerControl       *playerControl;    //播放器控制UI
@property (nonatomic, weak)   UIView                *superPlayView;    //播放的view
@property (nonatomic, assign) UIStatusBarStyle      barStyle;          //之前StatusBar样式

@property (nonatomic, assign) BOOL                  isCanPlay;         //视频是否可以播放
@property (nonatomic, assign) BOOL                  isLock;            //锁定(旋转、手势)
@property (nonatomic, assign) BOOL                  isFullScreen;      //当前是否全屏
@property (nonatomic, assign) UIDeviceOrientation   currentOrientiation; //当前屏幕方向


//手势相关
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;   //控制手势
@property (nonatomic, assign) double                 seekSumTime;      //快进总时长
@property (nonatomic, assign) PanDirection           panDirection;     //手指滑动方向
@property (nonatomic, assign) BOOL                   isVolume;         //是否调节音量
@property (nonatomic, strong) UISlider               *volumeSlider;    //系统音量控制

@end

static NIPlayer *player;
static dispatch_once_t onceToken;

@implementation NIPlayer

//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Lifecycle
+ (NIPlayer *)sharedPlayer {
    dispatch_once(&onceToken, ^{
        player = [[NIPlayer alloc] init];
    });
    return player;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.barStyle = APP.statusBarStyle;
        [self p_initUI];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self releasePlayer];
}


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Protocol
- (void)playerControl:(UIView *)control backAction:(UIButton *)sender {
    if (_isFullScreen) {
        _isLock = NO;
        [self fullScreen:UIDeviceOrientationPortrait];
        
    } else {
        if (self.getCurrentVC.presentingViewController) {
            [self.getCurrentVC dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.getCurrentNavVC popViewControllerAnimated:YES];
        }
    }
}
- (void)playerControl:(UIView *)control fullScreenAction:(UIButton *)sender {
    [self fullScreen:UIDeviceOrientationLandscapeLeft];
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
    __weak typeof(self) weakSelf = self;
    [self.avPlayer seekTo:seekTime completionHandler:^{
        weakSelf.playerControl.isFinishedSeek = YES;
    }];
}

- (void)playerControl:(UIView *)control sliderValueChangedAction:(UISlider *)sender {
    NSTimeInterval seekTime = sender.value * self.avPlayer.totalTime;
    NSTimeInterval totalTime = self.avPlayer.totalTime;
    if (!_isFullScreen) {
        [self.playerControl seekTo:seekTime totalTime:totalTime];
    } else {
        __weak typeof(self) weakSelf = self;
        [self.playerControl seekPipTo:sender.value * self.avPlayer.totalTime totalTime:self.avPlayer.totalTime];
        [self.avPlayer getCImage:sender.value * self.avPlayer.totalTime block:^(UIImage *image) {
            [weakSelf.playerControl seekToImage:image];
        }];
        [self.avPlayer startToSeek];
    }
    
}

#pragma mark ------ UITextFieldDelegate
#pragma mark ------ UITableViewDataSource
#pragma mark ------ UITableViewDelegate
#pragma mark ------ UIScrollViewDelegate



//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Override

#pragma mark ------ Public
- (void)playWithUrl:(NSString *)url onView:(UIView *)view {
    [self removeFromSuperview];
    [view addSubview:self];
    [self.playerControl reset];
    self.superPlayView = view;
    [self.avPlayer playWithUrl:url];
    [self p_configureVolume];
    [self p_initObserver];
}

- (void)play {
    [self.avPlayer play];
}

- (void)pause {
    [self.avPlayer pause];
}

- (void)releasePlayer {
    [self removeFromSuperview];
    [self.avPlayer releasePlayer];
    onceToken = 0;
    player = nil;
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
        make.edges.equalTo(self);
    }];
}

- (void)p_initObserver {
    [self p_initBlockObserver];
    [self p_initNotificatObserver];
   
}


- (void)p_removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)p_initNotificatObserver {
    //监听屏幕方向
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initScreenOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    //监听系统音量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initAudioVolumeObserver:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initaudioRouteChangeObserver:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)p_initBlockObserver {
    __weak typeof(self) weakSelf = self;
    //监听播放进度
    self.avPlayer.progressPlayBlock = ^(CGFloat value) {
        [weakSelf.playerControl seekTo:weakSelf.avPlayer.currentTime totalTime:weakSelf.avPlayer.totalTime];
    };
    
    //监听缓冲进度
    self.avPlayer.progressCacheBlock = ^(CGFloat value) {
        weakSelf.playerControl.progressSlider.cacheValue = value;
    };
    
    //监听播放状态
    self.avPlayer.statusBlock = ^(NIAVPlayerStatus status) {
        switch (status) {
            case NIAVPlayerStatusLoading: {
                [weakSelf.playerControl startLoading];
                break;
            }
            case NIAVPlayerStatusReadyToPlay: {
                [weakSelf.playerControl endLoading];
                weakSelf.isCanPlay = YES;
                weakSelf.playerControl.isPlay = YES;
                break;
            }
            case NIAVPlayerStatusPlayEnd: {
                weakSelf.playerControl.isPlay = NO;
                [weakSelf.avPlayer pause];
                break;
            }
            case NIAVPlayerStatusIsPlaying: {
                weakSelf.playerControl.isPlay = YES;
                break;
            }
            case NIAVPlayerStatusIsPaused: {
                weakSelf.playerControl.isPlay = NO;
                break;
            }
            case NIAVPlayerStatusCacheData: {
                [weakSelf.playerControl startLoading];
                break;
            }
            case NIAVPlayerStatusCacheEnd: {
                [weakSelf.playerControl endLoading];
                break;
            }
            case NIAVPlayerStatusPlayStop: {
                weakSelf.playerControl.isPlay = NO;
                [weakSelf.avPlayer pause];
                break;
            }
            case NIAVPlayerStatusItemFailed: {
                weakSelf.playerControl.isPlay = NO;
                [weakSelf.playerControl endLoading];
                [weakSelf.playerControl playError];
                break;
            }
            case NIAVPlayerStatusEnterBack: {
                if (weakSelf.isFullScreen) {
                    [weakSelf p_removeObserver];
                    
                    /** 全屏进入后台 竖屏状态回到前台 默认是全屏状态
                     *  不加下面默认是小屏进入后转到大屏效果不好
                     */
                    APP_DELEGATE.allowRotationType = AllowRotationMaskLandscapeLeftOrRight;
                }
                break;
            }
                
            case NIAVPlayerStatusBecomeActive: {
                if (weakSelf.isFullScreen) {
                    APP_DELEGATE.allowRotationType = AllowRotationMaskAllButUpsideDown;
                    [weakSelf p_initNotificatObserver];
                }
                break;
            }
                
            default:
                break;
        }
        
    };
}




#pragma mark 监听屏幕旋转
- (void)p_initScreenOrientationChanged:(id)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self fullScreen:orientation];
}

//监听系统音量改变
- (void)p_initAudioVolumeObserver:(id)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    self.volumeSlider.value = volume;
    
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
    _volumeSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeSlider = (UISlider *)view;
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

/** 添加播放器控制手势 */
- (void)p_addPanRecognizer {
    [self addGestureRecognizer:self.panRecognizer];
}
- (void)p_removePanRecognizer {
    [self removeGestureRecognizer:self.panRecognizer];
}

#pragma mark - Public
- (void)fullScreen:(UIDeviceOrientation)orientation {
    if (![self judgeIfCanRotate:orientation]) return;
    
    CGAffineTransform tranform = [self getRotateTransform:orientation];
    _currentOrientiation = orientation;
    
    if (orientation == UIDeviceOrientationLandscapeLeft
        ||orientation ==UIDeviceOrientationLandscapeRight ) { //全屏
        self.isFullScreen = YES;
        [self removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        if ( _avPlayer.videoSize.width < _avPlayer.videoSize.height) {
            //竖屏视频
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo([UIApplication sharedApplication].keyWindow);
            }];
            [self updateConstraintsIfNeeded];
            [self layoutIfNeeded];
            
            _isLock = YES;
            APP.statusBarStyle = UIStatusBarStyleLightContent;
            return;
        }
        
        CGFloat sw = [[UIScreen mainScreen] bounds].size.width;
        CGFloat sh = [[UIScreen mainScreen] bounds].size.height;
        CGFloat width = sw > sh ? sw : sh;
        CGFloat height = sh > sw ? sw : sh;
        [[NIBrightnessView sharedInstance] showWithTransform:tranform];
        [UIView animateWithDuration:0.3f animations:^{
            [self setTransform:tranform];
        }];
        
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
            make.center.equalTo([UIApplication sharedApplication].keyWindow);
        }];
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
        
        APP.statusBarOrientation = (UIInterfaceOrientation)orientation;
        APP.statusBarStyle = UIStatusBarStyleLightContent;
        APP.statusBarHidden = NO;
        
        //添加手势控制
        [self p_addPanRecognizer];
        
    } else if (orientation == UIDeviceOrientationPortrait) { //小屏幕
        [self removeFromSuperview];
        
        self.isFullScreen = NO;
        //移除亮度控制
        [[NIBrightnessView sharedInstance] removeFromSuperview];
        [self.superPlayView addSubview:self];
        [UIView animateWithDuration:0.3f animations:^{
            [self setTransform:tranform];
        }];
        
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.superPlayView);
        }];
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
        
        APP.statusBarOrientation = UIInterfaceOrientationPortrait;
        APP.statusBarStyle = _barStyle;
        APP.statusBarHidden = NO;
        
        //删除手势控制
        [self p_removePanRecognizer];
    }

    
}
//判断是否可以旋转
- (BOOL)judgeIfCanRotate:(UIDeviceOrientation)orientation {
    //视频不能播放禁止旋转
    if (!_isCanPlay) return NO;
    //屏幕方向未改变无需旋转
    if (_currentOrientiation == orientation) return NO;
    //竖屏视频锁定/全屏屏幕锁定时
    if (_isLock) return NO;
    if (orientation == UIDeviceOrientationPortrait ||
        orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight) {
    } else {
        return NO;
    }
    return YES;
}

//获取旋转角度
- (CGAffineTransform)getRotateTransform:(UIDeviceOrientation)orientation {
    CGAffineTransform tranform = CGAffineTransformIdentity;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        tranform = CGAffineTransformMakeRotation(M_PI_2);
    } else if (orientation == UIDeviceOrientationLandscapeRight){
        tranform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    return tranform;
}

//控制手势
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
                self.seekSumTime = self.avPlayer.currentTime;
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
            __weak typeof(self) weakSelf = self;
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self.avPlayer seekTo:self.seekSumTime completionHandler:^{
                        weakSelf.playerControl.isFinishedSeek = YES;
                    }];
                    self.seekSumTime = 0;
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
    self.seekSumTime += value / 200;
    
    // 需要限定sumTime的范围
    double totalSeconds = self.avPlayer.totalTime;
    if (self.seekSumTime > totalSeconds) { self.seekSumTime = totalSeconds;}
    if (self.seekSumTime < 0) { self.seekSumTime = 0; }
    
    BOOL style = false;
    if (value > 0) { style = YES; }
    if (value < 0) { style = NO; }
    if (value == 0) { return; }
    
    __weak typeof(self) weakSelf = self;
    [self.playerControl seekPipTo:self.seekSumTime totalTime:totalSeconds];
    [self.avPlayer getCImage:self.seekSumTime block:^(UIImage *image) {
        [weakSelf.playerControl seekToImage:image];
    }];
    [self.avPlayer startToSeek];
    
}

- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ getter setter
- (UIPanGestureRecognizer *)panRecognizer {
    if (!_panRecognizer) {
        _panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        _panRecognizer.delegate = self;
        [_panRecognizer setMaximumNumberOfTouches:1];
        [_panRecognizer setDelaysTouchesBegan:YES];
        [_panRecognizer setDelaysTouchesEnded:YES];
        [_panRecognizer setCancelsTouchesInView:YES];
    }
    return _panRecognizer;
}

- (void)setSuperPlayView:(UIView *)superPlayView {
    _superPlayView = superPlayView;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_superPlayView);
    }];
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    self.playerControl.isFullScreen = _isFullScreen;
}

@end
