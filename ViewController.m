//
//  ViewController.m
//  QHLRefreshDemo
//
//  Created by Qianhan on 15/10/8.
//  Copyright © 2015年 soffice. All rights reserved.
//

#import "ViewController.h"

#import "QHLRefreshHeader.h"
#import "QHLRefresh/QHLRefreshFooter.h"

@interface ViewController ()<UITableViewDataSource>

@property   (strong, nonatomic) QHLRefreshHeader *headerRefreshView;
@property   (strong, nonatomic) QHLRefreshFooter *footerRefreshView;
@property   (assign)    __block NSUInteger dataCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewDidLoad];
    self.title  = @"刷新";
    
    UITableView *tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            [[UIScreen mainScreen] bounds].size.width,
                                                                            [[UIScreen mainScreen] bounds].size.height-64)
                                                           style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.dataSource    = self;
    
    self.headerRefreshView  = [[QHLRefreshHeader alloc] initWithLogo:[UIImage imageNamed:@"Icon-Small.png"]
                                                   refreshScrollView:tableView];
    self.footerRefreshView  = [[QHLRefreshFooter alloc] initWithRefreshScrollView:tableView];
    
    self.headerRefreshView.strokeColor     = [UIColor redColor];
    __weak QHLRefreshHeader *refreshHeader = self.headerRefreshView;
    __weak ViewController   *selfViewController = self;
    self.headerRefreshView.refreshingBlock =^(){
        // 模拟刷新
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(3.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            
                           selfViewController.dataCount = 20;
                           selfViewController.footerRefreshView.isMore = YES;
                           [tableView reloadData];
            [refreshHeader finishRefreshing];
        });
    };
    [self.headerRefreshView startRefreshing];
    
    __weak QHLRefreshFooter *refreshFooter = self.footerRefreshView;
    self.footerRefreshView.refreshingBlock =^(){
        // 模拟刷新
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(3.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           
                           if (self.dataCount >= 60) {
                               
                               refreshFooter.isMore    = NO;
                           } else {
                               
                               selfViewController.dataCount += 20;
                               refreshFooter.isMore    = YES;
                           }
                           [tableView reloadData];
                           [refreshFooter finishRefreshing];
                       });
    };
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Index in row %ld", (long)indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
