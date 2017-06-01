//
//  SSVideoPlayController.h
//  SSVideoPlayer
//
//  Created by Mrss on 16/1/22.
//  Copyright © 2016年 expai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoModel : NSObject

@property (nonatomic,copy,readonly) NSString *path;
@property (nonatomic,copy,readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name path:(NSString *)path;
+ (instancetype)VideoModelWithName:(NSString *)name path:(NSString *)path;

@end

@protocol  VideoPlayControllerDelegate <NSObject>

- (void)fullScreen:(UIButton *)sender;

@end

@interface VideoPlayController : UIViewController

@property (nonatomic, weak) id<VideoPlayControllerDelegate> delegate;

//- (instancetype)initWithVideoList:(NSArray<VideoModel *> *)videoList;

- (instancetype)initWithVideo:(VideoModel *)video;
+ (instancetype)prepareWithVideo:(VideoModel *)video;

@end
