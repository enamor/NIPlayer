//
//  NIPlayerSlider.m
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NIPlayerSlider.h"
@interface NIPlayerSlider ()
@property (nonatomic,strong) UIImageView *thumb;

@end

@implementation NIPlayerSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, CGRectGetWidth(frame), 30)];
    [self addSubview:self.thumb];
    self.backgroundColor = [UIColor clearColor];
    self.minTrackColor = [UIColor colorWithRed:0.02 green:0.47 blue:0.98 alpha:1];
    self.maxTrackColor = [UIColor whiteColor];
    self.bufferTrackColor = [UIColor lightGrayColor];
    return self;
}

- (UIImageView *)thumb {
    if (_thumb == nil) {
        _thumb = [[UIImageView alloc]init];
        _thumb.bounds = CGRectMake(0, 0, 30, 30);
        _thumb.layer.cornerRadius = 15;
        _thumb.layer.masksToBounds = YES;
        _thumb.backgroundColor = [UIColor lightGrayColor];
        _thumb.contentMode = UIViewContentModeCenter;
    }
    return _thumb;
}

- (void)setThumbImage:(UIImage *)thumbImage {
    if (thumbImage) {
        self.thumb.image = thumbImage;
        self.thumb.backgroundColor = [UIColor clearColor];
    }
    else {
        self.thumb.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)setThumbImageHighlighted:(UIImage *)thumbImageHighlighted {
    if (thumbImageHighlighted) {
        self.thumb.highlightedImage = thumbImageHighlighted;
        self.thumb.backgroundColor = [UIColor clearColor];
    }
    else {
        self.thumb.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)setBufferValue:(float)bufferValue {
    bufferValue = [self valid:bufferValue];
    if (_bufferValue == bufferValue) {
        return;
    }
    _bufferValue = bufferValue;
    [self update];
}

- (void)setValue:(float)value {
    value = [self valid:value];
    if (_value == value) {
        return;
    }
    _value = value;
    [self update];
}

- (float)valid:(float)f {
    if (isnan(f)) {
        return 0.0;
    }
    if (fabs(f)<0.01) {
        return 0.0;
    }
    else if (fabs(f-1.0)<0.01) {
        return 1.0;
    }
    return f;
}



- (void)update {
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    self.thumb.center = CGPointMake(15+self.value*(CGRectGetWidth(self.bounds)-30), 15);
}

- (void)drawRect:(CGRect)rect {
    CGPoint from = CGPointMake(15, 15);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    [self strokePath:ctx withColor:self.maxTrackColor fromPoint:from toPoint:CGPointMake(CGRectGetWidth(self.bounds)-15, 15)];
    [self strokePath:ctx withColor:self.bufferTrackColor fromPoint:from toPoint:CGPointMake(15+(self.bufferValue*(CGRectGetWidth(rect)-30)), 15)];
    [self strokePath:ctx withColor:self.minTrackColor fromPoint:from toPoint:CGPointMake(15+(self.value*(CGRectGetWidth(rect)-30)), 15)];
}

- (void)strokePath:(CGContextRef)ctx withColor:(UIColor *)color fromPoint:(CGPoint)from toPoint:(CGPoint)to {
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextMoveToPoint(ctx, from.x, from.y);
    CGContextAddLineToPoint(ctx, to.x, to.y);
    CGContextStrokePath(ctx);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    if (!CGRectContainsPoint(self.thumb.frame, location)) {
        return NO;
    }
    self.thumb.highlighted = YES;
    _slide = YES;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    if (location.x <= CGRectGetWidth(self.bounds)-15 && location.x >= 15) {
        self.thumb.highlighted = YES;
        self.value = (location.x-15)/(CGRectGetWidth(self.bounds)-30);
        if (self.continuous) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    _slide = NO;
    self.thumb.highlighted = NO;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end

