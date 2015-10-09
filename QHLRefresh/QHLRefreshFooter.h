//
//  QHLRefreshFooter.h
//  QHLRefreshDemo
//
//  Created by Qianhan on 15/10/8.
//  Copyright © 2015年 soffice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 上拉刷新
@interface QHLRefreshFooter : NSObject

@property   (assign, nonatomic) BOOL    isMore; // 是否有更多，默认YES
/*
 * 刷新回调
 */
@property   (nonatomic, copy) void (^refreshingBlock)(void);

/*
 * 初始化
 */
- (instancetype)initWithRefreshScrollView:(UIScrollView *)scrollView;
/*
 * 开始加载
 */
- (void)startRefreshing;
/*
 * 加载结束
 */
- (void)finishRefreshing;

@end
