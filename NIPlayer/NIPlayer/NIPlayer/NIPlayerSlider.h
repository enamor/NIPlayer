//
//  NIPlayerSlider.h
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIPlayerSlider : UISlider
@property(nullable, nonatomic, strong) UIColor *cacheTrackTintColor;
@property (nonatomic, nonatomic, assign) CGFloat cacheValue;
@end


@interface NICacheSlider : UISlider

@end
