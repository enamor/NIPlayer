//
//  ZNVideoPlayer.m
//  AVPlayer
//
//  Created by zhouen on 17/1/4.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "ZNVideoPlayer.h"


static NSString *const VideoPlayerItemStatusKeyPath = @"status";
static NSString *const VideoPlayerItemLoadedTimeRangesKeyPath = @"loadedTimeRanges";

@interface ZNVideoPlayer ()

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *currentPlayItem;
@property (nonatomic,strong) id observer;

@end

@implementation ZNVideoPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _player = [[AVPlayer alloc]init];
        _displayMode = VideoPlayerDisplayModeAspectFit;
        _pausePlayWhenMove = YES;
    }
    return self;
}

- (void)playInContainer:(UIView *)container {
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    NSString *mode;
    switch (self.displayMode) {
        case VideoPlayerDisplayModeAspectFit:
            mode = AVLayerVideoGravityResizeAspect;
            break;
        default:
            mode = AVLayerVideoGravityResizeAspectFill;
            break;
    }
    self.playerLayer.videoGravity = mode;
    [container.layer addSublayer:self.playerLayer];
}
- (void)resetPlayContainer:(UIView *)container {
    self.playerLayer.frame = container.bounds;
}

- (void)setDisplayMode:(VideoPlayerDisplayMode)displayMode {
    if (_displayMode == displayMode) {
        return;
    }
    _displayMode = displayMode;
    NSString *mode;
    switch (displayMode) {
        case VideoPlayerDisplayModeAspectFit:
            mode = AVLayerVideoGravityResizeAspect;
            break;
        default:
            mode = AVLayerVideoGravityResizeAspectFill;
            break;
    }
    self.playerLayer.videoGravity = mode;
}

- (void)setPath:(NSString *)path {
    if (path == nil) {
        return;
    }
    if ([_path isEqualToString:path]) {
        return;
    }
    _path = path;
    if (self.playState == VideoPlayerPlayStatePlaying) {
        [self.player pause];
    }
    if (self.currentPlayItem) {
        if ([self.delegate respondsToSelector:@selector(videoPlayerDidSwitchPlay:)]) {
            [self.delegate videoPlayerDidSwitchPlay:self];
        }
        if (self.progressBlock) {
            self.progressBlock(0.0);
        }
        if (self.bufferProgressBlock) {
            self.bufferProgressBlock(0.0);
        }
        [self clear];
    }
    NSString *p = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL fileURLWithPath:p];
    if ([p hasPrefix:@"http://"] || [p hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:p];
    }
    AVPlayerItem *playItem = [[AVPlayerItem alloc]initWithURL:url];
    self.currentPlayItem = playItem;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playEndNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:playItem];
    [playItem addObserver:self forKeyPath:VideoPlayerItemStatusKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    [playItem addObserver:self forKeyPath:VideoPlayerItemLoadedTimeRangesKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    [self.player replaceCurrentItemWithPlayerItem:playItem];
    //    _duration = CMTimeGetSeconds(self.currentPlayItem.duration);
    __weak ZNVideoPlayer *weakSelf = self;
    self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
        if (CMTIME_IS_INDEFINITE(weakSelf.currentPlayItem.duration)) {
            return ;
        }
        float f = CMTimeGetSeconds(time);
        float max = CMTimeGetSeconds(weakSelf.currentPlayItem.duration);
        if (weakSelf.progressBlock) {
            weakSelf.progressBlock(f/max);
        }
    }];
}

- (void)clear {
    [self.player removeTimeObserver:self.observer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayItem];
    [self.currentPlayItem removeObserver:self forKeyPath:VideoPlayerItemLoadedTimeRangesKeyPath context:NULL];
    [self.currentPlayItem removeObserver:self forKeyPath:VideoPlayerItemStatusKeyPath context:NULL];
    self.currentPlayItem = nil;
}

- (void)playEndNotification {
    if (self.progressBlock) {
        self.progressBlock(1.0);
    }
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidEndPlay:)]) {
        [self.delegate videoPlayerDidEndPlay:self];
    }
}

- (void)playFailedNotification {
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidFailedPlay:)]) {
        [self.delegate videoPlayerDidFailedPlay:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:VideoPlayerItemStatusKeyPath]) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey]integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            if ([self.delegate respondsToSelector:@selector(videoPlayerDidReadyPlay:)]) {
                _duration = CMTimeGetSeconds(self.currentPlayItem.asset.duration);
                [self.delegate videoPlayerDidReadyPlay:self];
            }
        }
        else if (status == AVPlayerStatusFailed) {
            if ([self.delegate respondsToSelector:@selector(videoPlayerDidFailedPlay:)]) {
                [self.delegate videoPlayerDidFailedPlay:self];
            }
        }
    }
    else if ([keyPath isEqualToString:VideoPlayerItemLoadedTimeRangesKeyPath]) {
        if (CMTIME_IS_INDEFINITE(self.currentPlayItem.duration)) {
            return ;
        }
        NSArray *array = self.currentPlayItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float duration = CMTimeGetSeconds(self.currentPlayItem.asset.duration);
        float current = CMTimeGetSeconds(timeRange.duration);
        if (self.bufferProgressBlock) {
            self.bufferProgressBlock(current/duration);
        }
    }
}

- (VideoPlayerPlayState)playState {
    if (ABS(self.player.rate - 1) <= 0.000001) {
        return VideoPlayerPlayStatePlaying;
    }
    return VideoPlayerPlayStateStoped;
}

- (CMTime)currentTime {
   
    return self.player.currentTime;
}

- (CMTime)totalTime {
    return self.currentPlayItem.duration;
}
- (void)play {
    if (ABS(self.player.rate - 1) <= 0.000001) {
        return;
    }
    if (self.currentPlayItem.status == AVPlayerItemStatusFailed) {
        return;
    }
    [self.player play];
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidBeginPlay:)]) {
        [self.delegate videoPlayerDidBeginPlay:self];
    }
}

- (void)playAtTheBeginning {
    [self moveTo:0.0];
    [self play];
}

- (void)moveTo:(float)to {
    if (self.pausePlayWhenMove) {
        [self pause];
    }
    CMTime duration = self.currentPlayItem.asset.duration;
    float max = CMTimeGetSeconds(duration);
    long long l = ceil(max*to);
    [self.player seekToTime:CMTimeMake(l, 1)];
    if (self.progressBlock) {
        self.progressBlock(to);
    }
}

- (void)pause {
    if (ABS(self.player.rate - 0) <= 0.000001) {
        return;
    }
    [self.player pause];
}


- (void)dealloc {
    [self pause];
    [self clear];
    self.player = nil;
    self.playerLayer = nil;
    self.currentPlayItem = nil;
    self.observer = nil;
}

@end
