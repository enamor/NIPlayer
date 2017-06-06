//
//  ViewController.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "ViewController.h"
#import "NIPlayer.h"
#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NIPlayer *avPlayer = [[NIPlayer alloc] init];
    [self.view addSubview:avPlayer];
    
//    NSString *url = @"http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4";
    
    NSString *url = @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4";
    
//    NSString *url = [[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil];
    [avPlayer playWithUrl:url];
    
    CGFloat wid = [UIScreen mainScreen].bounds.size.width;
    CGFloat hei = [UIScreen mainScreen].bounds.size.height;
    CGFloat rate = wid < hei ? (wid/hei) : (hei/wid);
    [avPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(avPlayer.mas_width).multipliedBy(rate);
    }];
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}



@end
