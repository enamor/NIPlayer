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
#import "UIButton+Create.h"
#import "UILabel+Create.h"
#import "NSDate+NI_time.h"

@interface NIPlayerControl ()
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *fullBackBtn;
@property (nonatomic, strong) UIButton *miniBackBtn;
@property (nonatomic, readwrite, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *anthologyBtn;
@property (nonatomic, strong) UIButton *definitBtn;


@property (nonatomic, strong) UILabel *pipCurrentLabel;
@property (nonatomic, strong) UILabel *pipTotalLabel;
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
- (void)reset {
    self.progressSlider.cacheValue = 0;
    self.progressSlider.value = 0;
    
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"01:00:00";
    
    self.pipCurrentLabel.text = @"00:00";
    self.pipTotalLabel.text = @"01:00:00";
    
}
#pragma mark ------ IBAction


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Private
- (void)p_initUI {
    [self p_initTopBar];
    [self p_initBottomBar];
    [self p_initPIP];
}

- (void)p_initDatas {
    
}

- (void)p_initObserver {
    
}

- (void)p_initTopBar {
    self.topBar = [[UIView alloc] init];
    self.topBar.tag = 100;
    self.topBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:self.topBar];
    
    //占位
    UIView *spaceView = [[UIView alloc] init];
    [self.topBar addSubview:spaceView];
    [spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.topBar);
        make.height.mas_equalTo(20);
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
    
    //小屏退出
    self.miniBackBtn = [UIButton buttonWithImage:IMAGE_PATH(@"fullplayer_icon_back")];
    [_miniBackBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_miniBackBtn];
    [_miniBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_fullBackBtn);
    }];
    
    
    //满屏播放 ／ 比例播放
    UIButton *displayBtn = [UIButton buttonWithImage:IMAGE_PATH(@"miniplayer_icon_fullsize")];
    [displayBtn addTarget:self action:@selector(displayModeChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:displayBtn];
    [displayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.right.mas_equalTo(-8);
        make.width.mas_equalTo(28);
    }];
    
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(64);
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
    self.bottomBar = [[UIView alloc]init];
    self.bottomBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:self.bottomBar];
    
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
        make.width.mas_equalTo(80);
    }];
    
    //总时长 label
    self.totalTimeLabel = [UILabel labelWithText:@"00:00:00" fontSize:13 textColor:[UIColor whiteColor]];
    [self.bottomBar addSubview:_totalTimeLabel];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressSlider.mas_right).offset(4);
        make.centerY.equalTo(self.bottomBar);
        make.width.mas_equalTo(80);
    }];
    
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(44);
    }];

}

//画中画view
- (void)p_initPIP {
    UIView *pipView = [[UIView alloc] init];
    pipView.backgroundColor = [UIColor grayColor];
    [self addSubview:pipView];
    [pipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(100);
    }];
    
    self.pipImageView = [[UIImageView alloc] init];
    [pipView addSubview:_pipImageView];
    [self.pipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(pipView);
        make.bottom.equalTo(pipView).offset(-20);
    }];
    
    
    self.pipCurrentLabel = [UILabel labelWithText:@"00:00" fontSize:13 textColor:[UIColor whiteColor]];
    _pipCurrentLabel.textAlignment = NSTextAlignmentRight;
    [pipView addSubview:_pipCurrentLabel];
    [self.pipCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pipView.mas_bottom);
        make.left.bottom.equalTo(pipView);
        make.width.mas_equalTo(80);
    }];
    
    //总时长 label
    self.pipTotalLabel = [UILabel labelWithText:@"00:00:00" fontSize:13 textColor:[UIColor whiteColor]];
    [pipView addSubview:_pipTotalLabel];
    [self.pipTotalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pipView.mas_bottom);
        make.right.bottom.equalTo(pipView);
        make.width.mas_equalTo(80);
    }];

}
- (void)seekTo:(double)time totalTime:(double)totalTime; {
    NSString *dtime = [NSDate hourTime:time];
    NSString *dtotal = [NSDate hourTime:totalTime];
    self.pipCurrentLabel.text = dtime;
    self.pipTotalLabel.text = dtotal;
    
    self.currentTimeLabel.text = dtime;
    self.totalTimeLabel.text = dtotal;
    self.progressSlider.value = time/totalTime;
    
}

- (void)seekTo:(double)time totalTime:(double)totalTime image:(UIImage *)image {
    [self seekTo:time totalTime:totalTime];
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
    } else {
        [self.playButton setImage:BUNDLE_IMAGE(@"miniplayer_bottom_pause") selectedImage:BUNDLE_IMAGE(@"miniplayer_bottom_play")];

    }
}
@end
