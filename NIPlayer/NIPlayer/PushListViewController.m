//
//  PushListViewController.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/12.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "PushListViewController.h"
#import "NIPlayer.h"
#import "NIPlayerMacro.h"
#import "ViewController.h"

@interface PushListViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation PushListViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    APP_DELEGATE.allowRotationType = AllowRotationMaskPortrait;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //相对于上面的接口，这个接口可以动画的改变statusBar的前景色
    
    self.dataSource = @[@"http://7xqhmn.media1.z0.glb.clouddn.com/femorning-20161106.mp4",
                        @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
                        @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                        @"http://baobab.wdjcdn.com/14525705791193.mp4",
                        @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                        @"http://baobab.wdjcdn.com/1455782903700jy.mp4",
                        @"http://baobab.wdjcdn.com/14564977406580.mp4",
                        @"http://baobab.wdjcdn.com/1456316686552The.mp4",
                        @"http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                        @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                        @"http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                        @"http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                        @"http://baobab.wdjcdn.com/1456734464766B(13).mp4",
                        @"http://baobab.wdjcdn.com/1456653443902B.mp4",
                        @"http://baobab.wdjcdn.com/1456231710844S(24).mp4"];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"demo"];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"demo" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    ViewController *vc = [[ViewController alloc] init];
    vc.url = self.dataSource[indexPath.row];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (BOOL)shouldAutorotate {
    return NO;
}



@end
