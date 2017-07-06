//
//  NIPlayer.m
//  AVPlayer
//
//  Created by zhouen on 2017/5/31.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NIAVPlayer.h"

@interface NIAVPlayer ()

@property (nonatomic, strong) AVPlayer              *player;            //播放器
@property (nonatomic, strong) AVURLAsset            *urlAsset;
@property (nonatomic, strong) AVPlayerLayer         *playerLayer;
@property (nonatomic, strong) AVPlayerItem          *playerItem;        //视频资源
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;    //用于获取帧图像


@property (nonatomic, readwrite, assign) NSTimeInterval    totalTime;    //视频总长度
@property (nonatomic, readwrite, assign) NSTimeInterval    currentTime;  //当前进度
@property (nonatomic, readwrite, assign) NSTimeInterval    loadRange;    //缓存数据
@property (nonatomic, readwrite, assign) CGSize            videoSize;    //视频尺寸


@property (nonatomic ,strong) id    timeObserver;    //播放器观察者
@property (nonatomic ,assign) BOOL  isSeeking;       //拖动进度条的时候停止刷新数据
@property (nonatomic, assign) BOOL  isCanPlay;       //是否需要缓冲
@property (nonatomic, assign) BOOL  needBuffer;      //是否需要缓冲

@end
@implementation NIAVPlayer


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Lifecycle
- (instancetype)init {
    self = [super init];
    if (self) {
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
        
        if (!_isSeeking) {
            NSArray *array = _playerItem.loadedTimeRanges;
            CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
            self.loadRange = totalBuffer;
            CGFloat value = totalBuffer/self.totalTime;
            if (_progressCacheBlock) {
                _progressCacheBlock(value);
            }

        }
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
        if (self.playerItem.playbackBufferEmpty) {
            if (_statusBlock) {
                _statusBlock(NIAVPlayerStatusCacheData);
            }
        }
        //显示加载动画
//        if (self.isCanPlay) {
//            NSLog(@"跳转后没数据");
//            self.needBuffer = YES;
//            if (_statusBlock) {
//                _statusBlock(NIAVPlayerStatusCacheData);
//            }
//        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // 隐藏菊花
//        if (self.isCanPlay && self.needBuffer) {
//            NSLog(@"跳转后有数据");
//            self.needBuffer = NO;
//            if (_statusBlock) {
//                _statusBlock(NIAVPlayerStatusCacheEnd);
//            }
//        }
        
        if (self.playerItem.playbackLikelyToKeepUp)
        {
            // hide loading indicator
            if (_statusBlock) {
                _statusBlock(NIAVPlayerStatusCacheEnd);
            }
            if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
                // start playing
            }
            else if (_playerItem.status == AVPlayerStatusFailed) {
                // handle failed
            }
            else if (_playerItem.status == AVPlayerStatusUnknown) {
                // handle unknown
            }
        }
        
    }
}

#pragma mark ------ Public
#pragma 播放视频
- (void)playWithUrl:(NSString *)strUrl {
    if (!strUrl) {
        NSAssert(1<0, @"视频URL为空");
    }
    self.isCanPlay = NO;
#warning 需要处理中文路径过会再处理
    NSURL *url;
    if ([strUrl hasPrefix:@"http://"] || [strUrl hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:strUrl];
    } else { //本地视频 需要完整路径
        url = [NSURL fileURLWithPath:strUrl];
    }

    [self p_initPlayer:url];
    if (_statusBlock) {
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
        
        if (_statusBlock) {
            _statusBlock(NIAVPlayerStatusIsPlaying);
        }
    }
}

/** 暂停 */
- (void)pause {
    if (self.player.rate == 1.0) {
        [self.player pause];
        if (_statusBlock) {
            _statusBlock(NIAVPlayerStatusIsPlaying);
        }
    }
}


/** 拖动视频进度 */
- (void)seekTo:(NSTimeInterval)time completionHandler:(void(^)())complete{
    if (!self.isCanPlay) return;
    [self pause];
    [self startToSeek];
    __weak typeof(self)weakSelf = self;
    [self.player seekToTime:CMTimeMake(time, 1.0) completionHandler:^(BOOL finished) {
        [weakSelf endSeek];
        [weakSelf play];
        
        if (complete) {
            complete();
        }
    }];
    
}

/** 销毁并释放内存 */
- (void)releasePlayer {
    
    [self.player pause];
    [self.playerItem cancelPendingSeeks];
    [self.playerItem.asset cancelLoading];
    
    [self p_removeObserver];
    self.player = nil;
    self.playerItem = nil;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.timeObserver = nil;
    self.urlAsset = nil;
    self.imageGenerator = nil;
}

#pragma mark ------ IBAction


//////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Private
- (void)p_initUI {
    
}

//创建AVPlyer
- (void)p_initPlayer:(NSURL *)url{
    if (self.player) {
        //新视频重建播放器有利于内存更好的释放
        [self releasePlayer];
    }
    self.urlAsset = [AVURLAsset assetWithURL:url];
    // 初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    //用于获取帧图像的
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.urlAsset];
    
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    _playerLayer.frame = self.bounds;
    _playerLayer.videoGravity = [self p_getVideoGravity];
    _playerLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer insertSublayer:_playerLayer atIndex:0];

    //添加监听
    [self p_initObserver];
    
    
    //获取视频尺寸
//    __weak typeof(self) weakSelf = self;
//    [_urlAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
//        [weakSelf p_getVideoSize];
//    }];
}

//获取视频尺寸
- (void)p_getVideoSize{
    NSArray *array = self.urlAsset.tracks;
    for (AVAssetTrack *track in array) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            _videoSize = track.naturalSize;
            NSLog(@"%f",_videoSize.width);
            
        }
    }
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
    [center addObserver:self selector:@selector(videoPlayEnterBack:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)p_removeNotificatObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)p_initPlayerObserver {
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:nil usingBlock:^(CMTime time) {
        if (CMTIME_IS_INDEFINITE(weakSelf.playerItem.duration)) {
            return ;
        }
        if (weakSelf.isSeeking) {
            return;
        }
        float f = CMTimeGetSeconds(time);
        float max = weakSelf.totalTime;
        
        if (weakSelf.progressPlayBlock) {
            weakSelf.progressPlayBlock(f/max);
        }
    }];

    
    
}
- (void)p_removePlayerObserver {
    [self.player removeTimeObserver:self.timeObserver];
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


- (NSString *)p_getVideoGravity {
    NSString *mode;
    switch (_videoGravity) {
        case NIAVPlayerVideoGravityResizeAspect:
            mode = AVLayerVideoGravityResizeAspect;
            break;
        case NIAVPlayerVideoGravityResizeAspectFill:
            mode = AVLayerVideoGravityResizeAspectFill;
            break;
        case NIAVPlayerVideoGravityResize:
            mode = AVLayerVideoGravityResize;
            break;
        default:
            mode = AVLayerVideoGravityResizeAspect;
            break;
    }
    return mode;
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
            [self setNeedsLayout];
            [self layoutIfNeeded];
            NSLog(@"AVPlayerItemStatusReadyToPlay");
            self.isCanPlay = YES;
            [self.player play];
            _statusBlock(NIAVPlayerStatusReadyToPlay);
            [self p_getVideoSize];
            
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
//    [self.player seekToTime:kCMTimeZero];
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
    [self pause];
    if (_statusBlock) {
        _statusBlock(NIAVPlayerStatusEnterBack);
    }
}
/** 返回前台 */
- (void)videoPlayBecomeActive:(NSNotification *)notic {
    NSLog(@"返回前台");
    [self play];
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

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(self.playerItem.currentTime);
}
- (BOOL)isPlay {
    return self.player.rate;
}


- (void)getCImage:(double)time block:(void (^)(UIImage *image))block {
    if (!self.isCanPlay) {
        return;
    }
    CMTime dragedCMTime   = CMTimeMake(time, 1);
    [self.imageGenerator cancelAllCGImageGeneration];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    self.imageGenerator.maximumSize = CGSizeMake(150, 85);
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        NSLog(@"%zd",result);
        if (result != AVAssetImageGeneratorSucceeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        } else {
            UIImage *image = [UIImage imageWithCGImage:im];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(image);
                }
            });
        }
    };
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:dragedCMTime]] completionHandler:handler];

}


@end
