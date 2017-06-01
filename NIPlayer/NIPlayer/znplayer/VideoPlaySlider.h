//
//  VideoPlaySlider.h
//  AVPlayer
//
//  Created by zhouen on 17/1/4.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlaySlider : UIControl

@property (nonatomic,assign) float value; //0 - 1.
@property (nonatomic,assign) float bufferValue; //0 - 1.

@property (nonatomic,strong) UIColor *minTrackColor;
@property (nonatomic,strong) UIColor *maxTrackColor;
@property (nonatomic,strong) UIColor *bufferTrackColor;

@property (nonatomic,strong) UIImage *thumbImage;
@property (nonatomic,strong) UIImage *thumbImageHighlighted;

@property (nonatomic,assign) BOOL continuous; //Default NO.

@property (nonatomic,assign,readonly) BOOL slide;

@end
