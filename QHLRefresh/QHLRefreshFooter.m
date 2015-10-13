//
//  QHLRefreshFooter.m
//  QHLRefreshDemo
//
//  Created by Qianhan on 15/10/8.
//  Copyright © 2015年 soffice. All rights reserved.
//

#import "QHLRefreshFooter.h"

static const CGFloat    footRefreshHeight   = 36.0;

@interface QHLRefreshFooter () {
    
    BOOL  isRefresh;        // 是否正在加载
    BOOL  isLoading;        // 是否要加载
    CGFloat contentSizeHeight;  // scrollView可视内容高度
}

@property   (strong, nonatomic) UIScrollView    *refreshScrollView;
@property   (strong, nonatomic) UIView          *footView;
@property   (strong, nonatomic) UILabel         *footTitleLabel;
@property   (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation QHLRefreshFooter

- (instancetype)initWithRefreshScrollView:(UIScrollView *)scrollView {

    if (self = [super init]) {
        
        self.refreshScrollView  = scrollView;
        [self setup];
    }
    return self;
}

/*
 * 初始化
 */
- (void)setup {

    isRefresh   = NO;
    isLoading   = NO;
    self.isMore = YES;
    contentSizeHeight   = self.refreshScrollView.contentSize.height;
    [self.refreshScrollView  addSubview:self.footView];
    [self.footView  addSubview:self.footTitleLabel];
    [self.footView  addSubview:self.activityView];
    
    [self.refreshScrollView addObserver:self
                             forKeyPath:@"contentOffset"
                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGFloat currentOffsetY = self.refreshScrollView.contentOffset.y;
        contentSizeHeight      = self.refreshScrollView.contentSize.height;
        if (self.refreshScrollView.dragging) {
            
            if (!isRefresh) {
                
                self.activityView.hidden    = NO;
                CGFloat scrollFrameHeight   = self.refreshScrollView.frame.size.height;
                self.footView.frame         =   CGRectMake(0.0,
                                                           contentSizeHeight,
                                                           scrollFrameHeight,
                                                           footRefreshHeight);
                
                if (currentOffsetY + scrollFrameHeight > contentSizeHeight
                    && contentSizeHeight >= scrollFrameHeight) {
                    
                    isLoading  = YES;
                }
            }
        } else {
            
            if (isLoading && self.isMore) {
                
                [self startRefreshing];
            }
        }
    }
}

- (void)startRefreshing {

    if (!isRefresh) {
        
        isRefresh = YES;
        isLoading = NO;
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
        [UIView animateWithDuration:0.3 animations:^{
            
            self.refreshScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, footRefreshHeight, 0.0);
        }];
        _refreshingBlock();
    }
}

- (void)finishRefreshing {
    
    if (isRefresh) {
        
        isRefresh   = NO;
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.activityView stopAnimating];
            self.refreshScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        }];
    }
}

#pragma mark - getter/setter
- (UIView *)footView {

    if (!_footView) {
        
        _footView       = [[UIView alloc] init];
        _footView.frame = CGRectMake(0.0,
                                     self.refreshScrollView.frame.size.height + footRefreshHeight,
                                     self.refreshScrollView.frame.size.width,
                                     footRefreshHeight);
        _footView.backgroundColor   = [UIColor clearColor];
    }
    return _footView;
}

- (UILabel *)footTitleLabel {

    if (!_footTitleLabel) {
        
        _footTitleLabel         = [[UILabel alloc] init];
        _footTitleLabel.frame   = CGRectMake(0.0,
                                             0.0,
                                             self.footView.frame.size.width,
                                             self.footView.frame.size.height);
        _footTitleLabel.backgroundColor = [UIColor clearColor];
        _footTitleLabel.textAlignment   = NSTextAlignmentCenter;
        _footTitleLabel.font        = [UIFont systemFontOfSize:13.0];
        _footTitleLabel.textColor   = [UIColor grayColor];
        _footTitleLabel.text        = @"没有更多了";
        _footTitleLabel.hidden      = YES;
    }
    return _footTitleLabel;
}

- (UIActivityIndicatorView *)activityView {

    if (!_activityView) {
        
        _activityView   = [[UIActivityIndicatorView alloc] init];
        _activityView.center    = self.footTitleLabel.center;
        self.activityView.color = [UIColor grayColor];
        _activityView.hidden    = YES;
        [_activityView stopAnimating];
    }
    return _activityView;
}

@synthesize isMore  = _isMore;
- (BOOL)isMore {

    return _isMore;
}

- (void)setIsMore:(BOOL)isMore {

    _isMore = isMore;
    if (isMore
        && (self.refreshScrollView.contentSize.height >= self.refreshScrollView.frame.size.height)) {
        
        self.footTitleLabel.hidden  = YES;
        self.activityView.color     = [UIColor grayColor];
    } else {
        
        self.footTitleLabel.hidden  = NO;
        self.activityView.color     = [UIColor clearColor];
    }
}

- (void)dealloc{
    
    [self.refreshScrollView removeObserver:self forKeyPath:@"contentOffset"];
}


@end
