//
//  SSVideoPlayController.m
//  SSVideoPlayer
//
//  Created by Mrss on 16/1/22.
//  Copyright © 2016年 expai. All rights reserved.
//

#import "VideoPlayController.h"
#import "VideoPlaySlider.h"
#import "ZNVideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>
#import <UIKit/UIKit.h>
#import "ZNBrightnessView.h"


@implementation VideoModel

- (instancetype)initWithName:(NSString *)name path:(NSString *)path {
    self = [super init];
    if (self) {
        _name = [name copy];
        _path = [path copy];
    }
    return self;
}

+ (instancetype)VideoModelWithName:(NSString *)name path:(NSString *)path {
    return  [[VideoModel alloc] initWithName:name path:path];
}

@end

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

@interface VideoPlayController () <VideoPlayerDelegate ,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, weak) UIButton *fullScreenBtn;

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *playContainer;
@property (nonatomic, strong) ZNVideoPlayer *player;
@property (nonatomic, strong) NSMutableArray *videoPaths;
@property (nonatomic, strong) VideoModel *currentVideo;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) NSInteger playIndex;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;




/** 滑杆 */
@property (nonatomic, strong) UISlider               *volumeViewSlider;
/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat                sumTime;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection           panDirection;
/** 是否为全屏 */
@property (nonatomic, assign) BOOL                   isFullScreen;
/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL                   isLocked;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                   isVolume;



@end

@implementation VideoPlayController

#pragma mark ------ Lifecycle
- (instancetype)initWithVideoList:(NSArray<VideoModel *> *)videoList {
    NSAssert(videoList.count, @"The playlist can not be empty!");
    self = [super init];
    if (self) {
        self.videoPaths = [videoList mutableCopy];
    }
    return self;
}

- (instancetype)initWithVideo:(VideoModel *)video {
    self = [super init];
    if (self) {
        self.currentVideo = video;
    }
    return self;
}
+ (instancetype)prepareWithVideo:(VideoModel *)video {
    return [[VideoPlayController alloc] initWithVideo:video];
}


- (void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setupTopBar];
    [self setupBottomBar];
    [self configureVolume];
    
    [self.player playAtTheBeginning];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.player playInContainer:self.view];
    [self.view bringSubviewToFront:self.bottomBar];
    [self.view bringSubviewToFront:self.topBar];
    [self.view bringSubviewToFront:self.indicator];
    [self startIndicator];
    [self hide];
    
//    self.player.path = self.currentVideo.path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark ------ setter getter


#pragma mark ------ Public


#pragma mark ------ Private
- (void)p_setupSubview {
    
}


#pragma mark ------ Protocol
//VideoPlayerDelegate
- (void)videoPlayerDidReadyPlay:(ZNVideoPlayer *)videoPlayer {
    [self stopIndicator];
    [self.player play];
}

- (void)videoPlayerDidBeginPlay:(ZNVideoPlayer *)videoPlayer {
    self.playButton.selected = NO;
    
    // 添加平移手势，用来控制音量、亮度、快进快退
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    panRecognizer.delegate = self;
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelaysTouchesBegan:YES];
    [panRecognizer setDelaysTouchesEnded:YES];
    [panRecognizer setCancelsTouchesInView:YES];
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)videoPlayerDidEndPlay:(ZNVideoPlayer *)videoPlayer {
    self.playButton.selected = YES;
}

- (void)videoPlayerDidSwitchPlay:(ZNVideoPlayer *)videoPlayer {
    [self startIndicator];
}

- (void)videoPlayerDidFailedPlay:(ZNVideoPlayer *)videoPlayer {
    [self stopIndicator];
    [[[UIAlertView alloc]initWithTitle:@"该视频无法播放" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil]show];
}

#pragma mark ------ UITextFieldDelegate
#pragma mark ------ UITableViewDataSource
#pragma mark ------ UITableViewDelegate
#pragma mark ------ UIScrollViewDelegate
#pragma mark ------ Override


- (void)setup {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:self.indicator];
    
    //bar显示隐藏 手势
    UITapGestureRecognizer *panRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapRecognizer:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
    
    //监听屏幕方向
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

}


- (void)setupTopBar {
    self.topBar = [[UIView alloc] init];
    self.topBar.tag = 100;
    self.topBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.view addSubview:self.topBar];
    
    //占位
    UIView *spaceView = [[UIView alloc] init];
    [self.topBar addSubview:spaceView];
    [spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBar);
        make.left.equalTo(self.topBar);
        make.right.equalTo(self.topBar);
        make.height.mas_equalTo(20);
    }];
    
    //导航view
    UIView *contentView = [[UIView alloc] init];
    [self.topBar addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(spaceView.mas_bottom);
        make.bottom.equalTo(self.topBar);
        make.left.equalTo(self.topBar);
        make.right.equalTo(self.topBar);
    }];

    
    //退出
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[self imageWithName:@"player_quit"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(quit:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    //满屏播放 ／ 比例播放
    UIButton *displayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [displayBtn setBackgroundImage:[self imageWithName:@"player_fill"] forState:UIControlStateNormal];
    [displayBtn setBackgroundImage:[self imageWithName:@"player_fit"] forState:UIControlStateSelected];
    [displayBtn addTarget:self action:@selector(displayModeChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:displayBtn];
    [displayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(30);
    }];

    

    
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(64);
    }];
    
    
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.text = @"HH";
    [_titleLabel sizeToFit];

    
    
    
}

- (void)setupBottomBar {
    self.bottomBar = [[UIView alloc]init];
    self.bottomBar.tag = 100;
    self.bottomBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.view addSubview:self.bottomBar];
    
    //播放
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setBackgroundImage:[self imageWithName:@"player_pause"] forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[self imageWithName:@"player_play"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomBar addSubview:_playButton];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomBar);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(30);
    }];
    
    //全屏
    UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullScreenBtn setBackgroundImage:[self imageWithName:@"player_full"] forState:UIControlStateNormal];
    [fullScreenBtn setBackgroundImage:[self imageWithName:@"player_half"] forState:UIControlStateSelected];
    [fullScreenBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBar addSubview:fullScreenBtn];
    self.fullScreenBtn = fullScreenBtn;
    [fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomBar);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(30);
    }];
    
    
    //快进
    self.slider = [[UISlider alloc]init];
    [_slider setThumbImage:[self imageWithName:@"player_slider"] forState:UIControlStateNormal];
//    self.slider.thumbImage = [self imageWithName:@"player_slider"];
    [self.slider addTarget:self action:@selector(playProgressChange:) forControlEvents:UIControlEventValueChanged];
    [self.bottomBar addSubview:_slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomBar);
        make.left.equalTo(self.playButton.mas_right).offset(60);
        make.right.equalTo(fullScreenBtn.mas_left).offset(-60);
        make.height.mas_equalTo(30);
        
    }];
    
    
    //播放进度 label
    UILabel *currentLabel = [[UILabel alloc] init];
    currentLabel.font = [UIFont systemFontOfSize:13];
    currentLabel.textColor = [UIColor whiteColor];
    [self.bottomBar addSubview:currentLabel];
    [currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.slider.mas_left).offset(-4);
        make.centerY.equalTo(self.bottomBar);
    }];
    currentLabel.text = @"1:89:89";
    [currentLabel sizeToFit];
    
    //总时长 label
    UILabel *totalLabel = [[UILabel alloc] init];
    totalLabel.font = [UIFont systemFontOfSize:13];
    totalLabel.textColor = [UIColor whiteColor];
    [self.bottomBar addSubview:totalLabel];
    [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider.mas_right).offset(4);
        make.centerY.equalTo(self.bottomBar);
    }];
    totalLabel.text = @"1:89:89";
    [totalLabel sizeToFit];
    
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
}

#pragma mark 监听屏幕旋转
- (void)p_statusBarOrientationChanged:(id)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight ||
        orientation ==UIInterfaceOrientationLandscapeLeft) {
        self.isFullScreen = YES;
        self.fullScreenBtn.selected = YES;
    } else {
        self.isFullScreen = NO;
        self.fullScreenBtn.selected = NO;
    }

}

#pragma mark 全屏
- (void)fullScreen:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(fullScreen:)]) {
        [_delegate fullScreen:sender];
        self.isFullScreen = YES;
    }
    
    ZNBrightnessView *brightnessView = [ZNBrightnessView sharedInstance];
    [brightnessView show];
}
#pragma mark - Action

- (void)quit:(UIBarButtonItem *)item {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)displayModeChanged:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.player.displayMode = VideoPlayerDisplayModeAspectFill;
    }
    else {
        self.player.displayMode = VideoPlayerDisplayModeAspectFit;
    }
}

- (void)playProgressChange:(UISlider *)slider {
    [self.player moveTo:slider.value];
    if (!self.playButton.selected) {
        [self.player play];
    }
}

- (void)playAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player pause];
    }
    else {
        [self.player play];
    }
}

//下一集
- (void)next:(UIBarButtonItem *)item {
    if (self.playIndex >= self.videoPaths.count-1) {
        return;
    }
    self.playIndex++;
    VideoModel *model = self.videoPaths[self.playIndex];
    [self playVideoWithPath:model.path];
}

//上一集
- (void)previous:(UIBarButtonItem *)item {
    if (self.playIndex <= 0) {
        [self.player playAtTheBeginning];
        return;
    }
    self.playIndex--;
    VideoModel *model = self.videoPaths[self.playIndex];
    [self playVideoWithPath:model.path];
}

#pragma mark 播放
- (void)playVideoWithPath:(NSString *)path {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.player.path = path;
    });
}

- (void)startIndicator {
    if (![self.indicator isAnimating]) {
        [NSThread detachNewThreadSelector:@selector(startAnimating) toTarget:self.indicator withObject:nil];
    }
}

- (void)stopIndicator {
    if ([self.indicator isAnimating]) {
        [NSThread detachNewThreadSelector:@selector(stopAnimating) toTarget:self.indicator withObject:nil];
    }
}




- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.indicator.center = self.view.center;
    
    //播放窗口重置 只要是frame的变化
    [self.player resetPlayContainer:self.view];

}



- (ZNVideoPlayer *)player {
    if (_player == nil) {
        _player = [[ZNVideoPlayer alloc]init];
        _player.delegate = self;
        __weak VideoPlayController *weakSelf = self;
        _player.bufferProgressBlock = ^(float f) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.slider.bufferValue = f;
            });
        };
        _player.progressBlock = ^(float f) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf.slider) {
//                    weakSelf.slider.value = f;
                }
            });
        };
    }
    return _player;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player pause];
    self.player = nil;
}

- (void)barAnimation:(BOOL)animation {
    if (self.hidden) {
        [UIView animateWithDuration:0.15 animations:^{
            self.topBar.alpha = 1;
            self.bottomBar.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        } completion:^(BOOL finished) {
            self.hidden = NO;
            [self hide];
        }];
    } else {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBar) object:self];
        [self hideBar];
    }

}

- (void)hide {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBar) object:self];
    [self performSelector:@selector(hideBar) withObject:self afterDelay:4];
}

- (void)hideBar {
    [UIView animateWithDuration:0.15 animations:^{
        self.topBar.alpha = 0;
        self.bottomBar.alpha = 0;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}


- (UIImage *)imageWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"VideoPlayer" ofType:@"bundle"];
    NSString *imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",name]];
    return [UIImage imageWithContentsOfFile:imagePath];
}


#pragma mark - UIPanGestureRecognizer手势方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.topBar] ||
        [touch.view isDescendantOfView:self.bottomBar]) {
        return NO;
    }
    return YES;
}

- (void)tapRecognizer:(UITapGestureRecognizer *)tap {
    [self barAnimation:YES];
}

/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self.view];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self.view];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 取消隐藏
                self.panDirection = PanDirectionHorizontalMoved;
                // 给sumTime初值
                CMTime time       = self.player.currentTime;
                self.sumTime      = time.value/time.timescale;
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.view.bounds.size.width / 2) {
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
                    [self.player moveTo:self.sumTime];
//                    [self seekToTime:self.sumTime completionHandler:nil];
                    // 把sumTime滞空，不然会越加越多
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

/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value
{
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value
{
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    
    // 需要限定sumTime的范围
    CMTime totalTime           = self.player.totalTime;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    
    BOOL style = false;
    if (value > 0) { style = YES; }
    if (value < 0) { style = NO; }
    if (value == 0) { return; }
    
//    self.isDragged = YES;
//    [self.controlView zf_playerDraggedTime:self.sumTime totalTime:totalMovieDuration isForward:style hasPreview:NO];
}


/**
 *  获取系统音量
 */
- (void)configureVolume
{
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
    
    
//    [[[NSNotificationCenter defaultCenter]
//      rac_addObserverForName:@"AVSystemController_SystemVolumeDidChangeNotification"
//      object:nil]
//     subscribeNext:^(NSNotification *notification) {
//         float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
//         self.adjustView.voiceSlider.value = volume;
//     }
//     ];

    
}

@end
