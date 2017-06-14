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
#import "NIPlayerMacro.h"

@interface ViewController ()
@property (nonatomic, strong) NIPlayer *avPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *playView = [[UIView alloc ] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    [self.view addSubview:playView];
    _avPlayer = [[NIPlayer alloc] init];
    [self.view addSubview:_avPlayer];
    [_avPlayer playWithUrl:_url onView:playView];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    APP.statusBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    APP.statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)dealloc {
//    [_avPlayer releasePlayer];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}


@end
