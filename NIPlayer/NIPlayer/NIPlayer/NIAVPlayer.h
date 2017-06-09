//
//  NIPlayer.h
//  AVPlayer
//
//  Created by zhouen on 2017/5/31.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, NIAVPlayerStatus) {
    NIAVPlayerStatusLoading = 0,     // 加载视频
    NIAVPlayerStatusReadyToPlay,     // 准备好播放
    NIAVPlayerStatusPlayEnd,         // 播放结束
    NIAVPlayerStatusCacheData,       // 缓冲视频
    NIAVPlayerStatusCacheEnd,        // 缓冲结束
    NIAVPlayerStatusPlayStop,        // 播放中断 （多是没网）
    NIAVPlayerStatusItemFailed,      // 视频资源问题
    NIAVPlayerStatusEnterBack,       // 进入后台
    NIAVPlayerStatusBecomeActive,    // 从后台返回
    
};

typedef NS_ENUM(NSInteger,NIAVPlayerVideoGravity) {
    NIAVPlayerVideoGravityResizeAspect,
    NIAVPlayerVideoGravityResizeAspectFill
};

typedef NS_ENUM(NSInteger,NIAVPlayerProgressType) {
    NIAVPlayerProgressCache, //缓冲进度
    NIAVPlayerProgressPlay     //播放进度
};

//播放状态
typedef void(^NIAVPlayerStatusBlock)(NIAVPlayerStatus status);

//缓冲进度\播放进度
typedef void(^NIAVPlayerProgressBlock)(CGFloat value ,NIAVPlayerProgressType type);


@interface NIAVPlayer : UIView


@property (nonatomic, copy) NIAVPlayerProgressBlock progressBlock;
@property (nonatomic, copy) NIAVPlayerStatusBlock statusBlock;


@property (nonatomic, assign) NIAVPlayerVideoGravity videoGravity;
// 视频总长度
@property (nonatomic, assign) NSTimeInterval totalTime;
// 当前进度
@property (nonatomic, assign) NSTimeInterval currentTime;
// 缓存数据
@property (nonatomic, assign) NSTimeInterval loadRange;

@property (nonatomic, assign) BOOL isPlay;


/** 播放 */
- (void)play;

/** 暂停 */
- (void)pause;


/** 拖动视频进度 */
- (void)seekTo:(NSTimeInterval)time;

/** 播放视频 */
- (void)playWithUrl:(NSString *)strUrl;

- (void)startToSeek;

/** 彻底释放播放器 */
- (void)releasePlayer;

- (void)getCImage:(double)time block:(void (^)(UIImage *image))block;

@end
