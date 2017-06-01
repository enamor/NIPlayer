//
//  NIPlayerControl.h
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol  NIPlayerControlDelegate<NSObject>
- (void)playerControl:(UIView *)control fullScreenAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control playAction:(UIButton *)sender ;

@end
@interface NIPlayerControl : UIView
@property (nonatomic, strong) UIButton  *fullScreenButton;

@property (nonatomic, weak) id<NIPlayerControlDelegate> controlDelegate;
@end
