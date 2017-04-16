//
//  XZHViewController.m
//  MJRefreshExample
//
//  Created by 熊志华 on 16/5/30.
//  Copyright © 2016年 熊志华. All rights reserved.
//

#import "XZHViewController.h"
#import "XZHRefresh.h"

#import "MJRefresh.H"
#import "AFManager.h"

#define newVCload  @"http://np.iwenyu.cn/forum/index/index.html?page=%@"

NSString *const TableViewCellIdentifier = @"cell";

@interface XZHViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    int page;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation XZHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(handleStopRefresh)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    page=1;
    
    // Do any additional setup after loading the view.
}
- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    // 1.注册
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TableViewCellIdentifier];
    
    // 2.初始化假数据
    self.dataSource = [NSMutableArray array];
    
    // 3.集成刷新控件
    // 3.1.下拉刷新
    [self addHeader];
    
    // 3.2.上拉加载更多
    [self addFooter];
    
}


- (void)addHeader
{

    // 头部刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshAction)];
    
    [self.tableView.mj_header beginRefreshing];

    
}
- (void)addFooter
{
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshLoadMore)];
}
- (void)refreshAction {
    
    [self headerRefreshEndAction];
    
}
- (void)refreshLoadMore {
    
    [self footerRefreshEndAction];
    
}
- (void)headerRefreshEndAction {
    
    [self.dataSource removeAllObjects];
    
    NSString *strurl = [NSString stringWithFormat:newVCload,@"1"];
    [AFManager getReqURL:strurl block:^(id infor) {
        NSLog(@"infor=====%@",infor);
         NSLog(@"str====%@",strurl);
        NSArray *dit = [infor objectForKey:@"info"];
        NSLog(@"ddjdjdjdj----%lu",(unsigned long)dit.count);
        for (int i = 0; i<dit.count; i++) {
            NSDictionary *dicarr = [dit objectAtIndex:i];
            
            NSString *str = [[NSString alloc] init];
            str = dicarr[@"id"];
            [self.dataSource addObject:str];
        }

        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    } errorblock:^(NSError *error) {
        
    }];
    
  
}
- (void)footerRefreshEndAction {

    
    page ++;
    
    NSString *pnstr = [NSString stringWithFormat:@"%ld",(long)page];
    
    NSString *strurl = [NSString stringWithFormat:newVCload,pnstr];
    
    [AFManager getReqURL:strurl block:^(id infor) {
        NSLog(@"infor=====%@",infor);
        NSLog(@"str====%@",strurl);
        NSArray *dit = [infor objectForKey:@"info"];
        NSLog(@"ddjdjdjdj----%lu",(unsigned long)dit.count);
        for (int i = 0; i<dit.count; i++) {
            NSDictionary *dicarr = [dit objectAtIndex:i];
            
            NSString *str = [[NSString alloc] init];
            str = dicarr[@"id"];
            [self.dataSource addObject:str];
        }
        
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    } errorblock:^(NSError *error) {
        
    }];
    

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];
    /*上拉加载后 下拉刷新 --  数据越界崩溃
     */
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}
- (void)handleStopRefresh {
    [self.tableView.mj_header endRefreshing];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
