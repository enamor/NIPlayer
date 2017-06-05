//
//  NIPlayerSlider.m
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NIPlayerSlider.h"
#import <Masonry.h>
@interface NIPlayerSlider ()
@property (nonatomic,strong) UIProgressView *cacheProgress;

@property (nonatomic, strong) UISlider *cacheSlider;

@end

@implementation NIPlayerSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.continuous = YES ;
        self.maximumTrackTintColor = [UIColor clearColor];
        [self p_initUI];
    }
    return self;
}


- (void)p_initUI {
    self.cacheSlider = [[UISlider alloc] init];
    _cacheSlider.thumbTintColor = [UIColor clearColor];
    [self addSubview:_cacheSlider];
    _cacheSlider.userInteractionEnabled = NO;
    _cacheSlider.minimumTrackTintColor = [UIColor redColor];
    _cacheSlider.value = 0.9;
    
    [self.cacheSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setCacheTrackTintColor:(UIColor *)cacheTrackTintColor {
    _cacheTrackTintColor = cacheTrackTintColor;
    self.cacheSlider.minimumTrackTintColor = _cacheTrackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    [super setMaximumTrackTintColor:[UIColor clearColor]];
    _cacheSlider.maximumTrackTintColor = maximumTrackTintColor;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 3 ;
    rect.size.width = rect.size.width + 6;
    return [super thumbRectForBounds:bounds trackRect:rect value:value];
}
@end

