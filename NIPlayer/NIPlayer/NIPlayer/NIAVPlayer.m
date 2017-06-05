//
//  NIPlayer.m
//  AVPlayer
//
//  Created by zhouen on 2017/5/31.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NIAVPlayer.h"

@interface NIAVPlayer ()

@property (nonatomic, copy) NIAVPlayerStatusBlock statusBlock;
/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/** 视频资源 */
@property (nonatomic, strong) AVPlayerItem *playerItem;
/** 播放器观察者 */
@property (nonatomic ,strong)  id timeObser;
// 拖动进度条的时候停止刷新数据
@property (nonatomic ,assign) BOOL isSeeking;
// 是否需要缓冲
@property (nonatomic, assign) BOOL isCanPlay;
// 是否需要缓冲
@property (nonatomic, assign) BOOL needBuffer;

@end
@implementation NIAVPlayer


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        self.isCanPlay = NO;
        self.needBuffer = NO;
        self.isSeeking = NO;
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self p_removeObserver];
}



//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Protocol




//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Override
- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *item = object;
    if ([keyPath isEqualToString:@"status"]) {
        [self handleStatusWithPlayerItem:item];
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        // 计算缓冲进度
        //            NSTimeInterval timeInterval = [self availableDuration];
        //            CMTime duration             = self.playerItem.duration;
        //            CGFloat totalDuration       = CMTimeGetSeconds(duration);
        //            [self.controlView zf_playerSetProgress:timeInterval / totalDuration];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        
    }

}

#pragma mark ------ Public
#pragma 播放视频
- (void)playWithUrl:(NSString *)strUrl statusBlock:(NIAVPlayerStatusBlock)block{
    _statusBlock = block;
#warning 需要处理中文路径过会再处理
    NSURL *url;
    int type = 0; //0 本地视频、1 网络视频
    strUrl = [strUrl lowercaseString];
    if ([strUrl hasPrefix:@"http://"] || [strUrl hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:strUrl];
        type = 1;
    } else { //本地视频 需要完整路径
        url = [NSURL fileURLWithPath:strUrl];
    }

    
    [self p_initPlayer:url type:type];
    [_player play];
    
    if (block) {
        _statusBlock(NIAVPlayerStatusLoading);
    }
    
}

/**
 avplayer自身有一个rate属性
 rate ==1.0，表示正在播放；rate == 0.0，暂停；rate == -1.0，播放失败
 */

/** 播放 */
- (void)play {
    if (self.player.rate == 0) {
        [self.player play];
    }
}

/** 暂停 */
- (void)pause {
    if (self.player.rate == 1.0) {
        [self.player pause];
    }
}


/** 拖动视频进度 */
- (void)seekTo:(NSTimeInterval)time {
    [self pause];
    [self startToSeek];
    
    __weak typeof(self)weakSelf = self;
    [self.player seekToTime:CMTimeMake(time, 1.0) completionHandler:^(BOOL finished) {
        [weakSelf endSeek];
        [weakSelf play];
    }];
    
}

/** 销毁并释放内存 */
- (void)releasePlayer {
    [self.player pause];
    [self p_removeObserver];
    self.player = nil;
    self.playerItem = nil;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.timeObser = nil;
}

#pragma mark ------ IBAction


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Private
- (void)p_initUI {
    
}

//创建AVPlyer
- (void)p_initPlayer:(NSURL *)url type:(int)type{
    if (self.player) {
        //新视频重建播放器有利于内存更好的释放
        [self releasePlayer];
        
    }
    
    if (type == 0) {
        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    } else {
        self.playerItem = [AVPlayerItem playerItemWithURL:url];
    }
    
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //设置模式
    NSString *mode;
    switch (_videoGravity) {
        case NIAVPlayerVideoGravityResizeAspect:
            mode = AVLayerVideoGravityResizeAspect;
            break;
        default:
            mode = AVLayerVideoGravityResizeAspectFill;
            break;
    }
    _playerLayer.videoGravity = mode;
    _playerLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer insertSublayer:_playerLayer atIndex:0];

    //添加监听
    [self p_initObserver];
    
}


/**
 添加重要通知监听
 AVPlayerItemDidPlayToEndTimeNotification     视频播放结束通知
 AVPlayerItemPlaybackStalledNotification      视频异常中断通知
 UIApplicationDidEnterBackgroundNotification  进入后台
 UIApplicationDidBecomeActiveNotification     返回前台
 */
- (void)p_initObserver {
    [self p_initNotificatObserver];
    [self p_initPlayerObserver];
    [self p_initPlayItemObserver:_playerItem];
}

- (void)p_removeObserver {
    [self p_removeNotificatObserver];
    [self p_removePlayerObserver];
    [self p_removePlayItemObserver:_playerItem];
}

- (void)p_initNotificatObserver {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(videoPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayError:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayEnterBack:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)p_removeNotificatObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)p_initPlayerObserver {
    __weak typeof(self) weakSelf = self;
    self.timeObser = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
        if (CMTIME_IS_INDEFINITE(weakSelf.playerItem.duration)) {
            return ;
        }
        float f = CMTimeGetSeconds(time);
        float max = CMTimeGetSeconds(weakSelf.playerItem.duration);
#warning todo
//        if (weakSelf.progressBlock) {
//            weakSelf.progressBlock(f/max);
//        }
    }];
    
}
- (void)p_removePlayerObserver {
    [self.player removeTimeObserver:self.timeObser];
}

- (void)p_initPlayItemObserver:(AVPlayerItem *)item {
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)p_removePlayItemObserver:(AVPlayerItem *)item {
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}



/**
 处理 AVPlayerItem 播放状态
 AVPlayerItemStatusUnknown           状态未知
 AVPlayerItemStatusReadyToPlay       准备好播放
 AVPlayerItemStatusFailed            播放出错
 */
- (void)handleStatusWithPlayerItem:(AVPlayerItem *)item {
    AVPlayerItemStatus status = item.status;
    if (!_statusBlock) return;
    switch (status) {
        case AVPlayerItemStatusReadyToPlay:   // 准备好播放
            
            NSLog(@"AVPlayerItemStatusReadyToPlay");
            self.isCanPlay = YES;
            [self.player play];
            _statusBlock(NIAVPlayerStatusReadyToPlay);
            
            break;
        case AVPlayerItemStatusFailed:        // 播放出错
            
            NSLog(@"AVPlayerItemStatusFailed");
            _statusBlock(NIAVPlayerStatusItemFailed);
            
            break;
        case AVPlayerItemStatusUnknown:       // 状态未知

            NSLog(@"AVPlayerItemStatusUnknown");
            
            break;
            
        default:
            break;
    }
    
}


/** 视频播放结束 */
- (void)videoPlayEnd:(NSNotification *)notic {
    NSLog(@"视频播放结束");
    if (_statusBlock) {
        _statusBlock(NIAVPlayerStatusPlayEnd);
    }
    [self.player seekToTime:kCMTimeZero];
}
/** 视频异常中断 */
- (void)videoPlayError:(NSNotification *)notic {
    NSLog(@"视频异常中断");
    if (_statusBlock) {
        _statusBlock(NIAVPlayerStatusPlayStop);
    }
}
/** 进入后台 */
- (void)videoPlayEnterBack:(NSNotification *)notic {
    NSLog(@"进入后台");
    if (_statusBlock) {
        _statusBlock(NIAVPlayerStatusEnterBack);
    }
}
/** 返回前台 */
- (void)videoPlayBecomeActive:(NSNotification *)notic {
    NSLog(@"返回前台");
    if (_statusBlock) {
        _statusBlock(NIAVPlayerStatusBecomeActive);
    }
}


/** 跳动中不监听 */
- (void)startToSeek {
    self.isSeeking = YES;
}
- (void)endSeek {
    self.isSeeking = NO;
}


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ getter setter
- (NSTimeInterval)totalTime {
    return CMTimeGetSeconds(self.playerItem.duration);
}

- (BOOL)isPlay {
    return self.player.rate;
}


@end