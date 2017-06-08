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
//        self.continuous = NO ;
        self.maximumTrackTintColor = [UIColor clearColor];
        [self p_initUI];
    }
    return self;
}


- (void)p_initUI {
    self.cacheSlider = [[NICacheSlider alloc] init];
    _cacheSlider.thumbTintColor = [UIColor clearColor];
    [self addSubview:_cacheSlider];
    _cacheSlider.userInteractionEnabled = NO;
    
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

- (void)setCacheValue:(CGFloat)cacheValue {
    _cacheValue = cacheValue;
    self.cacheSlider.value = _cacheValue;
}


- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 3 ;
    rect.size.width = rect.size.width + 6;
    return [super thumbRectForBounds:bounds trackRect:rect value:value];
}

@end

@implementation NICacheSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 11 ;
    rect.size.width = rect.size.width + 22;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 11 , 11);
}

@end

