//
//  XMGInifiteScrollView.m
//  无限滚动
//
//  Created by xiaomage on 16/3/4.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

#import "XMGInifiteScrollView.h"
#import "UIImageView+WebCache.h"

@interface XMGInifiteScrollView() <UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
/** 定时器 */
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation XMGInifiteScrollView

/** scrollView中UIImageView的数量 */
static NSInteger XMGImageViewCount = 3;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // UIScrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.pagingEnabled = YES;
        // 去除弹簧效果
        scrollView.bounces = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView.backgroundColor = [UIColor greenColor];
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        // UIImageView
        for (NSInteger i = 0; i < XMGImageViewCount; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)]];
            [scrollView addSubview:imageView];
        }
        
        // UIPageControl
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        
        // 时间间隔
        self.interval = 1.5;
        
        // 滚动方向
        self.scrollDirection = XMGInifiteScrollDirectionHorizontal;
        
        // 占位图片
        self.placeholder = [UIImage imageNamed:@"XMGInifiteScrollView.bundle/placeholder"];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat selfW = self.frame.size.width;
    CGFloat selfH = self.frame.size.height;
    
    // UIScrollView
    self.scrollView.frame = self.bounds;
    if (self.scrollDirection == XMGInifiteScrollDirectionHorizontal) {
        self.scrollView.contentSize = CGSizeMake(XMGImageViewCount * selfW, 0);
    } else {
        self.scrollView.contentSize = CGSizeMake(0, XMGImageViewCount * selfH);
    }
    
    // UIImageView
    for (NSInteger i = 0; i < XMGImageViewCount; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        if (self.scrollDirection == XMGInifiteScrollDirectionHorizontal) {
            imageView.frame = CGRectMake(i * selfW, 0, selfW, selfH);
        } else {
            imageView.frame = CGRectMake(0, i * selfH, selfW, selfH);
        }
    }
    
    // UIPageControl
    CGFloat pageControlW = 100;
    CGFloat pageControlH = 25;
    self.pageControl.frame = CGRectMake(selfW - pageControlW, selfH - pageControlH, pageControlW, pageControlH);
    
    // 更新内容
    [self updateContentAndOffset];
}

#pragma mark - 监听点击
/**
 *  图片点击
 */
- (void)imageClick:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(inifiteScrollView:didClickImageAtIndex:)]) {
        [self.delegate inifiteScrollView:self didClickImageAtIndex:tap.view.tag];
    }
}

#pragma mark - 私有方法
/**
 *  更新图片内容和scrollView的偏移量
 */
- (void)updateContentAndOffset
{
    // 1.更新imageView上面的图片内容
    for (NSInteger i = 0; i < XMGImageViewCount; i++) { // i是用来获取imageView的
        UIImageView *imageView = self.scrollView.subviews[i];
        
        // 根据当前页码求出imageIndex
        NSInteger imageIndex = 0;
        if (i == 0) { // 左边
            imageIndex = self.pageControl.currentPage - 1;
            if (imageIndex == -1) { // 显示最后面一张
                imageIndex = self.images.count - 1;
            }
        } else if (i == 1) { // 中间
            imageIndex = self.pageControl.currentPage;
        } else if (i == 2) { // 右边
            imageIndex = self.pageControl.currentPage + 1;
            if (imageIndex == self.images.count) { // 显示最前面一张
                imageIndex = 0;
            }
        }
        
        imageView.tag = imageIndex;
        // 图片数据
        id obj = self.images[imageIndex];
        if ([obj isKindOfClass:[UIImage class]]) { // UIImage对象
            imageView.image = obj;
        } else if ([obj isKindOfClass:[NSString class]]) { // 本地图片名
            imageView.image = [UIImage imageNamed:obj];
        } else if ([obj isKindOfClass:[NSURL class]]) { // 远程图片URL
            [imageView sd_setImageWithURL:obj placeholderImage:self.placeholder];
        }
    }
    
    // 2.设置scrollView.contentOffset.x = 1倍宽度
    if (self.scrollDirection == XMGInifiteScrollDirectionHorizontal) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    } else {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
    }
}

#pragma mark - setter
- (void)setInterval:(NSTimeInterval)interval
{
    _interval = interval;
    
    [self stopTimer];
    [self startTimer];
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    
    // 总页数
    self.pageControl.numberOfPages = images.count;
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 找出显示在最中间的imageView
    UIImageView *middleImageView = nil;
    // x值和偏移量x的最小差值
    CGFloat minDelta = MAXFLOAT;
    for (NSInteger i = 0; i < XMGImageViewCount; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        
        // x值和偏移量x差值最小的imageView，就是显示在最中间的imageView
        CGFloat currentDelta = 0;
        if (self.scrollDirection == XMGInifiteScrollDirectionHorizontal) {
            currentDelta = ABS(imageView.frame.origin.x - self.scrollView.contentOffset.x);
        } else {
            currentDelta = ABS(imageView.frame.origin.y - self.scrollView.contentOffset.y);
        }
        if (currentDelta < minDelta) {
            minDelta = currentDelta;
            middleImageView = imageView;
        }
    }
    
    self.pageControl.currentPage = middleImageView.tag;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateContentAndOffset];
}

/**
 *  用户即将开始拖拽的时候调用
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

/**
 *  用户手松开的时候调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

#pragma mark - 定时器
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextPage
{
    [UIView animateWithDuration:0.25 animations:^{
        if (self.scrollDirection == XMGInifiteScrollDirectionHorizontal) {
            self.scrollView.contentOffset = CGPointMake(2 * self.scrollView.frame.size.width, 0);
        } else {
            self.scrollView.contentOffset = CGPointMake(0, 2 * self.scrollView.frame.size.height);
        }
    } completion:^(BOOL finished) {
        [self updateContentAndOffset];
    }];
}
@end
