//
//  HomeViewController.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/16.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeTableViewCell.h"
#import "HomeVideoModel.h"
#import "NIPlayer.h"
#import <MJRefresh/MJRefresh.h>
#import "HttpRequest.h"
#import <MJExtension/MJExtension.h>

#define VIDEO_URL(page) [NSString stringWithFormat:@"http://c.m.163.com/nc/video/list/V9LG4B3A0/y/%d-100.html",(page-1)*10]

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) int page;

@property (nonatomic, strong) NIPlayer *player;
@end

static NSString *const reuseIdentifier = @"homeCell";
@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _page = 1;
    [self.tableView registerClass:[HomeTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    _player = [[NIPlayer alloc] init];
    
    [self p_initPullRefresh];
    
    self.tableView.scrollsToTop = NO;
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)p_initPullRefresh {
    
    __weak typeof(self) weakSelf = self;
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            NSString *url = [NSString stringWithFormat:@"http://c.m.163.com/nc/video/list/V9LG4B3A0/y/0-10.html?time=%lf",time] ;

        [[HttpRequest shareInstance] getRequestWithURL:url parameters:nil success:^(id response) {
            NSArray *array = response[@"V9LG4B3A0"];
            if (array.count > 0) {
                [self.dataSource removeAllObjects];
            }
            NSArray *data = [HomeVideoModel mj_objectArrayWithKeyValuesArray:array];
            [weakSelf.dataSource addObjectsFromArray:data];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        } failure:^(id error) {
            [weakSelf.tableView.mj_header endRefreshing];
        }];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [[HttpRequest shareInstance] getRequestWithURL:VIDEO_URL(++_page) parameters:nil success:^(id response) {
            NSArray *array = response[@"V9LG4B3A0"];
            NSArray *data = [HomeVideoModel mj_objectArrayWithKeyValuesArray:array];
            [weakSelf.dataSource addObjectsFromArray:data];
            [weakSelf.tableView reloadData];
        } failure:^(id error) {
            
        }];
    }];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [HomeTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    HomeVideoModel *model = self.dataSource[indexPath.row];
    cell.videoModel = model;
    __weak typeof(self) weakSelf = self;
    cell.playActionBlock = ^{
        weakSelf.currentIndexPath = indexPath;
        [_player playWithUrl:model.mp4_url onView:cell.videoImageView];
    };
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *indexpaths = [self.tableView indexPathsForVisibleRows];
    if (![indexpaths containsObject:_currentIndexPath]&&_currentIndexPath) {//复用
        [_player releasePlayer];
        _currentIndexPath = nil;
        
    }
}


- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (BOOL)shouldAutorotate {
    return NO;
}
@end
