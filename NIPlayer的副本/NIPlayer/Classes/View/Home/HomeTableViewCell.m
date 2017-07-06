//
//  HomeTableViewCell.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/16.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "UILabel+NI_Create.h"
#import "UIButton+NI_Create.h"
#import "HomeVideoModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface HomeTableViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *playBtn;
@end
@implementation HomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self p_setupUI];
    }
    return self;
}


- (void)p_setupUI {
    self.videoImageView = [[UIImageView alloc] init];
    [self addSubview:_videoImageView];
    _videoImageView.userInteractionEnabled = YES;
    
    self.playBtn = [UIButton buttonWithImage:@"play"];
    [self.videoImageView addSubview:_playBtn];
    [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [UILabel labelWithFontSize:14 textColor:[UIColor blackColor]];
    [self addSubview:_titleLabel];
}

- (void)setVideoModel:(HomeVideoModel *)videoModel {
    _videoModel = videoModel;
    [_videoImageView sd_setImageWithURL:[NSURL URLWithString:_videoModel.cover] placeholderImage:nil];
    _titleLabel.text = _videoModel.title;
}

- (void)playAction {
    if (_playActionBlock) {
        _playActionBlock();
    }
}

- (void)layoutSubviews {
    CGFloat screenW = self.frame.size.width;
    CGFloat bgH = screenW * 9 / 16;
    _videoImageView.frame = CGRectMake(0, 0, screenW, bgH);
    _playBtn.frame = CGRectMake((screenW - 40)/2.0, (bgH - 40)/2.0, 40, 40);
    _titleLabel.frame = CGRectMake(0, bgH, screenW, 30);
}

+ (CGFloat)cellHeight {
    CGFloat bgH = [UIScreen mainScreen].bounds.size.width * 9 / 16;
    return bgH + 30 + 15;
}

@end
