//
//  HomeTableViewCell.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/16.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeVideoModel;

@interface HomeTableViewCell : UITableViewCell
@property (nonatomic, copy) void (^playActionBlock)();

@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong)HomeVideoModel *videoModel;

+ (CGFloat)cellHeight;
@end
