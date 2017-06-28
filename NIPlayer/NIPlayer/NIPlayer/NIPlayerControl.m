//
//  NIPlayerControl.m
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NIPlayerControl.h"
#import "NIPlayerMacro.h"
#import "NIPlayerSlider.h"
#import <Masonry.h>
#import "UIButton+NI_Create.h"
#import "UILabel+NI_Create.h"
#import "NSDate+NI_time.h"
#import "UIImage+NI_Extension.h"

@interface NIPlayerControl ()
@property (nonatomic, strong) UIImageView *topBar;
@property (nonatomic, strong) UIImageView *bottomBar;


@property (nonatomic, strong) UILabel           *titleLabel;         //标题
@property (nonatomic, strong) UIButton          *fullBackBtn;        //全屏时返回
@property (nonatomic, strong) UIButton          *miniBackBtn;        //小屏时返回
@property (nonatomic, strong) UIButton          *playButton;         //播放
@property (nonatomic, strong) UIButton          *nextButton;         //下一集
@property (nonatomic, strong) UIButton          *anthologyBtn;       //选集
@property (nonatomic, strong) UIButton          *definitBtn;         //清晰度
@property (nonatomic, strong) UIButton          *errorBtn;           //播放失败展示


@property (nonatomic, strong) UIActivityIndicatorView *indicator;     //菊花


@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UIView *pipView;
@property (nonatomic, strong) UILabel *pipTimeLabel;
@property (nonatomic, strong) UIImageView *pipImageView;


@end

@implementation NIPlayerControl

//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initUI];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Protocol
#pragma mark ------ UITextFieldDelegate
#pragma mark ------ UITableViewDataSource
#pragma mark ------ UITableViewDelegate
#pragma mark ------ UIScrollViewDelegate



//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Override

#pragma mark ------ Public
- (void)startLoading {
    [self addSubview:self.indicator];
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.indicator startAnimating];
}
- (void)endLoading {
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
}

- (void)playError {
    [self addSubview:_errorBtn];
    [_errorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(128);
    }];
}

- (void)removeError {
    [self.errorBtn removeFromSuperview];
}

- (void)reset {
    self.progressSlider.cacheValue = 0;
    self.progressSlider.value = 0;
    
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"01:00:00";
    
    self.pipTimeLabel.text = @"00:00";
    self.pipImageView.image = nil;
    
    [self endLoading];
    [self removeError];
    
}
#pragma mark ------ IBAction


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Private
- (void)p_initUI {
    [self p_initTopBar];
    [self p_initBottomBar];
    [self p_initErrorUI];
    [self p_initPIP];
}

- (void)p_initDatas {
    
}

- (void)p_initObserver {
    
}

- (void)p_initTopBar {
    self.topBar = [[UIImageView alloc] init];
    _topBar.userInteractionEnabled = YES;
    _topBar.image = [UIImage resizedImageWithName:IMAGE_PATH(@"miniplayer_mask_top")];
    self.topBar.tag = 100;
    [self addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(64);
    }];
    
    //占位
    UIView *spaceView = [[UIView alloc] init];
    [self.topBar addSubview:spaceView];
    [spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.topBar);
        make.height.mas_equalTo(0);
    }];
    
    //导航view
    UIView *contentView = [[UIView alloc] init];
    [self.topBar addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(spaceView.mas_bottom);
        make.left.right.bottom.equalTo(self.topBar);
    }];
    
    
    //全屏退出
    self.fullBackBtn = [UIButton buttonWithImage:IMAGE_PATH(@"fullplayer_icon_back")];
    [_fullBackBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_fullBackBtn];
    [_fullBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.left.mas_equalTo(8);
        make.width.mas_equalTo(28);
    }];
    _fullBackBtn.hidden = YES;
    
    
    return;
    //小屏退出
    self.miniBackBtn = [UIButton buttonWithImage:IMAGE_PATH(@"fullplayer_icon_back")];
    [_miniBackBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_miniBackBtn];
    [_miniBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_fullBackBtn);
    }];
    
    
    
    //满屏播放 ／ 比例播放
    UIButton *displayBtn = [UIButton buttonWithImage:IMAGE_PATH(@"fullplayer_icon_more")];
//    [displayBtn addTarget:self action:@selector(displayModeChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:displayBtn];
    [displayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.right.mas_equalTo(-8);
        make.width.mas_equalTo(28);
    }];
    
    
    self.titleLabel = [UILabel labelWithFontSize:15 textColor:[UIColor whiteColor]];
    _titleLabel.text = @"ddd";
    [contentView addSubview:_titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_fullBackBtn.mas_right);
        make.right.equalTo(displayBtn.mas_left);
        make.top.bottom.equalTo(contentView);
    }];
}

- (void)p_initBottomBar {
    self.bottomBar = [[UIImageView alloc]init];
    _bottomBar.userInteractionEnabled = YES;
    _bottomBar.image = [UIImage resizedImageWithName:IMAGE_PATH(@"miniplayer_mask_bottom")];
    [self addSubview:self.bottomBar];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    //播放
    self.playButton = [UIButton buttonWithImage:IMAGE_PATH(@"miniplayer_bottom_pause") selectedImage:IMAGE_PATH(@"miniplayer_bottom_play")];
    _playButton.adjustsImageWhenHighlighted = NO;
    [_bottomBar addSubview:_playButton];
    [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomBar);
        make.left.mas_equalTo(8);
    }];
    
    //快进
    self.nextButton = [UIButton buttonWithImage:IMAGE_PATH(@"fullplayer_icon_next")];
    _nextButton.adjustsImageWhenHighlighted = NO;
    _nextButton.hidden = YES;
    [_bottomBar addSubview:_nextButton];
    [_nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomBar);
        make.left.equalTo(_playButton.mas_right).offset(10);
    }];
    
    
    //全屏
    self.fullScreenBtn = [UIButton buttonWithImage:IMAGE_PATH(@"miniplayer_icon_fullsize")];
    _fullScreenBtn.adjustsImageWhenHighlighted = NO;
    [_bottomBar addSubview:_fullScreenBtn];
    [_fullScreenBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomBar);
        make.right.mas_equalTo(-8);
    }];
    
    
    //选集
    self.anthologyBtn = [UIButton buttonWithTitle:@"选集" fontSize:14 textColor:[UIColor whiteColor]];
    [_bottomBar addSubview:_anthologyBtn];
    _anthologyBtn.hidden = YES;
    
    [_anthologyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.bottomBar);
        make.right.equalTo(self.bottomBar).offset(-8);
        make.width.mas_equalTo(_anthologyBtn.frame.size.width + 15);
        
    }];
    
    //清晰度
    self.definitBtn = [UIButton buttonWithTitle:@"高清" fontSize:14 textColor:[UIColor whiteColor]];
    [_bottomBar addSubview:_definitBtn];
    _definitBtn.hidden = YES;
    
    [_definitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.bottomBar);
        make.right.equalTo(_anthologyBtn.mas_left);
        make.width.mas_equalTo(_definitBtn.frame.size.width + 15);
        
    }];
    
    
    //快进
    self.progressSlider = [[NIPlayerSlider alloc]init];
    [_progressSlider setThumbImage:BUNDLE_IMAGE(@"fullplayer_progress_point") forState:UIControlStateNormal];
    _progressSlider.minimumTrackTintColor = HEX_COLOR(0xF1B795);
    _progressSlider.maximumTrackTintColor = [UIColor blackColor];
    _progressSlider.cacheTrackTintColor = [UIColor lightGrayColor];

    // slider开始滑动事件
//    [_progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [_progressSlider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [_progressSlider addTarget:self action:@selector(seekAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    [self.bottomBar addSubview:_progressSlider];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomBar);
        make.left.equalTo(self.playButton.mas_right).offset(60);
        make.right.equalTo(_fullScreenBtn.mas_left).offset(-60);
        make.height.mas_equalTo(30);
        
    }];
    
    
    //播放进度 label
    self.currentTimeLabel = [UILabel labelWithText:@"00:00" fontSize:13 textColor:[UIColor whiteColor]];
    _currentTimeLabel.textAlignment = NSTextAlignmentRight;
    [self.bottomBar addSubview:_currentTimeLabel];
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.progressSlider.mas_left).offset(-4);
        make.centerY.equalTo(self.bottomBar);
        make.width.mas_equalTo(60);
    }];
    
    //总时长 label
    self.totalTimeLabel = [UILabel labelWithText:@"00:00" fontSize:13 textColor:[UIColor whiteColor]];
    [self.bottomBar addSubview:_totalTimeLabel];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressSlider.mas_right).offset(4);
        make.centerY.equalTo(self.bottomBar);
        make.width.mas_equalTo(60);
    }];

}

//画中画view
- (void)p_initPIP {
    
    self.pipView = [[UIView alloc] init];
    _pipView.hidden = YES;
    _pipView.backgroundColor = [UIColor blackColor];
    [self addSubview:_pipView];
    [self.pipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(105);
    }];
    
    self.pipImageView = [[UIImageView alloc] init];
    [_pipView addSubview:_pipImageView];
    [self.pipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(_pipView);
        make.bottom.equalTo(_pipView).offset(-20);
    }];
    
    
    self.pipTimeLabel = [UILabel labelWithText:@"00:00" fontSize:13 textColor:[UIColor whiteColor]];
    _pipTimeLabel.textAlignment = NSTextAlignmentCenter;
    [_pipView addSubview:_pipTimeLabel];
    [self.pipTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pipImageView.mas_bottom);
        make.left.right.bottom.equalTo(_pipView);
    }];
}

- (void)p_initErrorUI {
    self.errorBtn = [UIButton buttonWithTitle:@"播放失败" fontSize:14 textColor:[UIColor whiteColor] image:IMAGE_PATH(@"play_error")];
    _errorBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    _errorBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [_errorBtn addTarget:self action:@selector(errorAction:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)seekTo:(double)time totalTime:(double)totalTime {
    NSString *dtime = [NSDate hourTime:time];
    NSString *dtotal = [NSDate hourTime:totalTime];
    
    self.currentTimeLabel.text = dtime;
    self.totalTimeLabel.text = dtotal;
    self.progressSlider.value = time/totalTime;
    
}

- (void)seekPipTo:(double)time totalTime:(double)totalTime {
    self.pipView.hidden = NO;
    [self seekTo:time totalTime:totalTime];
    NSString *dtime = [NSDate hourTime:time];
    NSString *dtotal = [NSDate hourTime:totalTime];
    self.pipTimeLabel.text = [NSString stringWithFormat:@"%@/%@",dtime,dtotal];
}

- (void)seekToImage:(UIImage *)image {
    self.pipImageView.image = image;
}



- (void)backAction:(UIButton *)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:backAction:)]) {
        [_controlDelegate playerControl:self backAction:sender];
    }
}

- (void)fullScreen:(UIButton *)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:fullScreenAction:)]) {
        [_controlDelegate playerControl:self fullScreenAction:sender];
    }
}

- (void)playAction:(UIButton *)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:playAction:)]) {
        [_controlDelegate playerControl:self playAction:sender];
    }
}

- (void)errorAction:(UIButton *)sender {
    _errorBtn.hidden = YES;
    if ([_controlDelegate respondsToSelector:@selector(playerControl:errorAction:)]) {
        [_controlDelegate playerControl:self errorAction:sender];
    }
}

- (void)nextAction:(UIButton *)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:nextAction:)]) {
        [_controlDelegate playerControl:self nextAction:sender];
    }
}

- (void)seekAction:(UISlider *)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:seekAction:)]) {
        [_controlDelegate playerControl:self seekAction:sender];
    }
}
- (void)sliderValueChangedAction:(UISlider *)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:sliderValueChangedAction:)]) {
        [_controlDelegate playerControl:self sliderValueChangedAction:sender];
    }
}

//////////////////////////////////////////////////////////////////////////////

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicator;
}


#pragma mark ------ getter setter
- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    
    _fullScreenBtn.selected = _isFullScreen;
    _fullBackBtn.hidden = !_isFullScreen;
    _fullScreenBtn.hidden = _isFullScreen;
    _nextButton.hidden = !_isFullScreen;
    _anthologyBtn.hidden = !_isFullScreen;
    _definitBtn.hidden = !_isFullScreen;
    
    if (_isFullScreen) {
        [self.playButton setImage:BUNDLE_IMAGE(@"fullplayer_icon_pause") selectedImage:BUNDLE_IMAGE(@"fullplayer_icon_play")];
        
        [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomBar);
            make.left.equalTo(self.playButton.mas_right).offset(100);
            make.right.equalTo(_fullScreenBtn.mas_left).offset(-120);
            make.height.mas_equalTo(30);
        }];
        
        
    } else {
        [self.playButton setImage:BUNDLE_IMAGE(@"miniplayer_bottom_pause") selectedImage:BUNDLE_IMAGE(@"miniplayer_bottom_play")];
        
        [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomBar);
            make.left.equalTo(self.playButton.mas_right).offset(60);
            make.right.equalTo(_fullScreenBtn.mas_left).offset(-60);
            make.height.mas_equalTo(30);
        }];
    }
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)setIsPlay:(BOOL)isPlay {
    _isPlay = isPlay;
    _playButton.selected = !_isPlay;
}

- (void)setIsFinishedSeek:(BOOL)isFinishedSeek {
    _isFinishedSeek = isFinishedSeek;
    if (_isFinishedSeek) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            _pipView.hidden = YES;
        });
    }
}
@end
