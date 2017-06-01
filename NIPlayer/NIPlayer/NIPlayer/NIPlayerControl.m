//
//  NIPlayerControl.m
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NIPlayerControl.h"
#import "NIPlayerSlider.h"
#import <Masonry.h>

@interface NIPlayerControl ()
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) NIPlayerSlider *progressSlider;

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

#pragma mark ------ IBAction


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Private
- (void)p_initUI {
    [self p_initTopBar];
    [self p_initBottomBar];
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
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(64);
    }];
    
    
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.text = @"HH";
    [contentView addSubview:_titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backBtn.mas_right);
        make.right.equalTo(displayBtn.mas_left);
        make.top.bottom.equalTo(contentView);
    }];
}

- (void)p_initBottomBar {
    self.bottomBar = [[UIView alloc]init];
    self.bottomBar.tag = 100;
    self.bottomBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:self.bottomBar];
    
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
    self.fullScreenButton = fullScreenBtn;
    [fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomBar);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(30);
    }];
    
    
    //快进
    self.progressSlider = [[NIPlayerSlider alloc]init];
    _progressSlider.thumbImage = [self imageWithName:@"player_slider"];
    [_progressSlider addTarget:self action:@selector(playProgressChange:) forControlEvents:UIControlEventValueChanged];
    [self.bottomBar addSubview:_progressSlider];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.right.equalTo(self.progressSlider.mas_left).offset(-4);
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
        make.left.equalTo(self.progressSlider.mas_right).offset(4);
        make.centerY.equalTo(self.bottomBar);
    }];
    totalLabel.text = @"1:89:89";
    [totalLabel sizeToFit];
    
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(44);
    }];

}

- (UIImage *)imageWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"VideoPlayer" ofType:@"bundle"];
    NSString *imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",name]];
    return [UIImage imageWithContentsOfFile:imagePath];
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

//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ getter setter
@end
