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
#pragma mark ------ UITextFieldDelegate
#pragma mark ------ UITableViewDataSource
#pragma mark ------ UITableViewDelegate
#pragma mark ------ UIScrollViewDelegate



//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Override

#pragma mark ------ Public
- (void)playWithUrl:(NSString *)url {
    [self.avPlayer playWithUrl:url statusBlock:^(NIAVPlayerStatus status) {
        
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
