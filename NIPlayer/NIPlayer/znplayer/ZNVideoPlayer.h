//
//  ZNVideoPlayer.h
//  AVPlayer
//
//  Created by zhouen on 17/1/4.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ZNVideoPlayer;

@protocol VideoPlayerDelegate <NSObject>

@optional

- (void)videoPlayerDidReadyPlay:(ZNVideoPlayer *)videoPlayer;

- (void)videoPlayerDidBeginPlay:(ZNVideoPlayer *)videoPlayer;

- (void)videoPlayerDidEndPlay:(ZNVideoPlayer *)videoPlayer;

- (void)videoPlayerDidSwitchPlay:(ZNVideoPlayer *)videoPlayer;

- (void)videoPlayerDidFailedPlay:(ZNVideoPlayer *)videoPlayer;

@end

typedef NS_ENUM(NSInteger,VideoPlayerPlayState) {
    VideoPlayerPlayStatePlaying,
    VideoPlayerPlayStateStoped,
};

typedef NS_ENUM(NSInteger,VideoPlayerDisplayMode) {
    VideoPlayerDisplayModeAspectFit,
    VideoPlayerDisplayModeAspectFill
};

@interface ZNVideoPlayer : NSObject

@property (nonatomic,  weak) id <VideoPlayerDelegate> delegate;

@property (nonatomic,  copy) void (^progressBlock)(float progress);

@property (nonatomic,  copy) void (^bufferProgressBlock)(float progress);

@property (nonatomic,assign,readonly) VideoPlayerPlayState playState;

@property (nonatomic,  copy) NSString *path; //Support both local and remote resource.

@property (nonatomic,assign) BOOL pausePlayWhenMove; //Default YES.

@property (nonatomic,assign,readonly) float duration;
@property (nonatomic,assign) CMTime totalTime;
@property (nonatomic,assign) CMTime currentTime;

@property (nonatomic,assign) VideoPlayerDisplayMode displayMode;

- (void)playInContainer:(UIView *)container ;
- (void)resetPlayContainer:(UIView *)container ;

- (void)play;

- (void)playAtTheBeginning;

- (void)moveTo:(float)to; //0 to 1.

- (void)pause;

@end

