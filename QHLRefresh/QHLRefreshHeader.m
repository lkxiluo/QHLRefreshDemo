//
//  QHLRefreshHeader.m
//  QHLRefreshDemo
//
//  Created by Qianhan on 15/10/8.
//  Copyright © 2015年 soffice. All rights reserved.
//

#import "QHLRefreshHeader.h"

typedef NS_ENUM(NSUInteger, QHLRefreshStatues) {
    
    QHLRefreshStatuesNone = 0,      // 还未开始
    QHLRefreshStatuesLoading = 1,   // 正在加载
};

static const CGFloat    imageWidth      = 18.0;     // 圆形，高宽相等
static const CGFloat    refreshHeight   = 36.0;     // 加载的高度
static const CGFloat    labelWidth      = 65.0;     // 标题长度
static const CGFloat    space           = 10.0;     // 间隔
static const CGFloat    maxStrokeEnd    = 0.80;     // 旋转图层的最大值

@interface QHLRefreshHeader () {
    
    BOOL  isRefresh;        // 是否正在加载
    CGFloat lastPosition;
    QHLRefreshStatues   refreshStatues;
}

@property   (strong, nonatomic) UIScrollView    *refreshScrollView;
@property   (strong, nonatomic) UIImageView     *logoImageView;     // 图标
@property   (strong, nonatomic) UILabel         *headerLabel;       // 显示的文字
@property   (strong, nonatomic) CAShapeLayer    *revolveLayer;      // 旋转图层


@end

@implementation QHLRefreshHeader

- (instancetype)initWithLogo:(UIImage *)logoImage refreshScrollView:(UIScrollView *)scrollView {

    if (self = [super init]) {
    
        self.refreshScrollView      = scrollView;
        self.logoImageView.image    = logoImage;
        [self setup];
    }
    return self;
}

/*
 * 初始化
 */
- (void)setup {

    isRefresh  = NO;
    refreshStatues  = QHLRefreshStatuesNone;
    [self.refreshScrollView.layer   addSublayer:self.revolveLayer];
    [self.refreshScrollView  addSubview:self.logoImageView];
    [self.refreshScrollView  addSubview:self.headerLabel];
    
    [self.refreshScrollView addObserver:self
                             forKeyPath:@"contentOffset"
                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                context:nil];
}

- (void)startRefreshing {

    if (!isRefresh) {
        
        isRefresh   = YES;
        self.headerLabel.text   = @"正在加载···";
        refreshStatues  = QHLRefreshStatuesLoading;
        self.revolveLayer.strokeEnd = maxStrokeEnd;
        [self startAnimation];
        [UIView animateWithDuration:0.3 animations:^{
            
            self.refreshScrollView.contentInset = UIEdgeInsetsMake(refreshHeight * 1.5, 0.0, 0.0, 0.0);
        }];
        _refreshingBlock();
    }
}

- (void)finishRefreshing {

    if (isRefresh) {
        
        isRefresh   = NO;
        self.headerLabel.text   = @"下拉可刷新";
        refreshStatues  = QHLRefreshStatuesNone;
        [UIView animateWithDuration:0.3 animations:^{
            
            self.refreshScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            [self finishAnimation];
        }];
    }
}

- (void)startAnimation {
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue  = [NSNumber numberWithFloat:0.0];
    rotationAnimation.toValue    = [NSNumber numberWithFloat:M_PI * 2];
    rotationAnimation.duration      = 0.4;
    rotationAnimation.repeatCount   = INFINITY;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [self.revolveLayer addAnimation:rotationAnimation forKey:@"Refreshing"];
}

- (void)finishAnimation {

    [self.revolveLayer removeAllAnimations];
}

/*
 * 根据键值的改变调整状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (self.refreshScrollView.dragging) {
           
            if (!isRefresh) {
                
                CGFloat currentOffsetY = self.refreshScrollView.contentOffset.y;
                if (currentOffsetY <= - (refreshHeight * 2.0)) {
                    
                    self.revolveLayer.strokeEnd = maxStrokeEnd;
                    self.headerLabel.text   = @"释放可刷新";
                    refreshStatues  = QHLRefreshStatuesLoading;
                } else {
                    
                    CGFloat     startHeight = -refreshHeight * 0.5;     // 计算的起始偏移
                    if (currentOffsetY <= startHeight) {
                        
                        self.revolveLayer.strokeEnd = (currentOffsetY - startHeight) / (-refreshHeight * 2.0) * maxStrokeEnd;
                    } else {
                    
                        self.revolveLayer.strokeEnd = 0.0;
                    }
                    refreshStatues  = QHLRefreshStatuesNone;
                }
            }
        } else {
        
            switch (refreshStatues) {
                case QHLRefreshStatuesNone: {
                    
                    self.headerLabel.text   = @"下拉可刷新";
                    break;
                }
                    
                case QHLRefreshStatuesLoading: {
                
                    self.headerLabel.text   = @"正在加载···";
                    [self startRefreshing];
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
}

#pragma mark -getter/setter
- (UIImageView *)logoImageView {

    if (!_logoImageView) {
        
        _logoImageView      = [[UIImageView alloc] init];
        _logoImageView.frame            = CGRectMake((self.refreshScrollView.frame.size.width
                                                      - (imageWidth + space + labelWidth)) / 2,
                                                     - refreshHeight,
                                                     imageWidth,
                                                     imageWidth);
        _logoImageView.backgroundColor      = [UIColor clearColor];
        _logoImageView.layer.cornerRadius   = imageWidth / 2;
    }
    
    return _logoImageView;
}

- (UILabel *)headerLabel {

    if (!_headerLabel) {
        
        _headerLabel        = [[UILabel alloc] init];
        _headerLabel.frame  = CGRectMake(self.logoImageView.frame.origin.x + imageWidth + space,
                                         self.logoImageView.frame.origin.y,
                                         labelWidth,
                                         imageWidth);
        _headerLabel.backgroundColor    = [UIColor clearColor];
        _headerLabel.font       = [UIFont systemFontOfSize:13.0];
        _headerLabel.textColor  = [UIColor grayColor];
        _headerLabel.textAlignment  = NSTextAlignmentCenter;
        _headerLabel.text       = @"下拉可刷新";
    }
    
    return _headerLabel;
}

- (CAShapeLayer *)revolveLayer {

    if (!_revolveLayer) {
        
        _revolveLayer       = [CAShapeLayer layer];
        _revolveLayer.frame = CGRectMake(self.logoImageView.frame.origin.x - 2.0,
                                         self.logoImageView.frame.origin.y - 2.0,
                                         imageWidth + 4.0,
                                         imageWidth + 4.0);
        _revolveLayer.strokeColor   = self.strokeColor.CGColor;
        _revolveLayer.fillColor     = [UIColor clearColor].CGColor;
        _revolveLayer.strokeStart   = 0.0;
        _revolveLayer.strokeEnd     = 0.0;
        _revolveLayer.lineWidth     = 1.0;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake((imageWidth + 4.0) / 2,
                                                                               (imageWidth + 4.0) / 2)
                                                            radius:(imageWidth + 4.0) / 2
                                                        startAngle:0.0
                                                          endAngle:M_PI * 2
                                                         clockwise:YES];
        _revolveLayer.path = path.CGPath;
    }
    return _revolveLayer;
}

@synthesize strokeColor = _strokeColor;
- (UIColor *)strokeColor {

    if (_strokeColor == nil) {
        
        _strokeColor = [UIColor grayColor];
    }
    return _strokeColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor {

    _strokeColor                    = strokeColor;
    self.revolveLayer.strokeColor   = strokeColor.CGColor;
}

- (void)dealloc{
    
    [self.refreshScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

@end





