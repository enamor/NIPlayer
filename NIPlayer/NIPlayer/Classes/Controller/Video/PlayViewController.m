//
//  PlayViewController.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/16.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "PlayViewController.h"
#import "NIPlayer.h"

@interface PlayViewController ()
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 245)];
    [self.view addSubview:playView];
    
    [[NIPlayer sharedPlayer] playWithUrl:_url onView:playView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NIPlayer sharedPlayer] releasePlayer];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotate {
    return NO;
}

@end
