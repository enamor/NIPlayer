//
//  VideoListViewController.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/7.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "VideoListViewController.h"
#import "NIPlayer.h"
#import "NIPlayerMacro.h"
#import "VideoCell.h"

@interface VideoListViewController ()
@property (nonatomic, strong) NIPlayer *player;
@property (nonatomic, assign) NSIndexPath *playIndexPath;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation VideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _player = [[NIPlayer alloc] init];
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
    
    [self.tableView registerClass:[VideoCell class] forCellReuseIdentifier:@"demo"];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [VideoCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"demo" forIndexPath:indexPath];
    
    NSArray *indexpaths = [tableView indexPathsForVisibleRows];
    if (![indexpaths containsObject:_playIndexPath]&&_playIndexPath) {//复用
        [_player releasePlayer];
        _playIndexPath = nil;
        
    }else{
        
    }

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_playIndexPath == indexPath) {
        return;
    }
    [_player removeFromSuperview];
    self.playIndexPath = indexPath;
    VideoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.bgImageView addSubview:_player];
    _player.frame = cell.bgImageView.bounds;
    [_player playWithUrl:_dataSource[indexPath.row] onView:cell.bgImageView];
    
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
