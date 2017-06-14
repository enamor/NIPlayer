//
//  VideoCell.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/14.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "VideoCell.h"
#import "UILabel+Create.h"
#import "NIPlayerMacro.h"

@interface VideoCell ()

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation VideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self p_setupUI];
    }
    return self;
}


- (void)p_setupUI {
    self.titleLabel = [UILabel labelWithFontSize:14 textColor:[UIColor blueColor]];
    [self addSubview:_titleLabel];
    
    self.bgImageView = [[UIImageView alloc] init];
    _bgImageView.image = [UIImage imageNamed:@"texst"];
    _bgImageView.userInteractionEnabled = YES;
    
    [self addSubview:_bgImageView];
    self.bottomView = [[UIView alloc] init];
    [self addSubview:_bottomView];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20);
    
    CGFloat bgH = self.frame.size.width * 9 / 16;
    self.bgImageView.frame = CGRectMake(0, 20, SCREEN_WIDTH, bgH);
}

+ (CGFloat)cellHeight {
    return  SCREEN_WIDTH * 9 / 16 + 20;
}
@end
