//
//  ViewController.m
//  无限滚动
//
//  Created by xiaomage on 16/3/4.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

#import "ViewController.h"
#import "XMGInifiteScrollView.h"

@interface ViewController () <XMGInifiteScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMGInifiteScrollView *scrollView = [[XMGInifiteScrollView alloc] init];
//    scrollView.scrollDirection = XMGInifiteScrollDirectionVertical;
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    scrollView.images = @[
                          [NSURL URLWithString:@"http://123/png"],
                          [NSURL URLWithString:@"http://img1.bdstatic.com/static/home/widget/search_box_home/logo/home_white_logo_0ddf152.png"],
                          [UIImage imageNamed:@"img_00"],
                          @"img_01",
                          [UIImage imageNamed:@"img_02"],
                          [UIImage imageNamed:@"img_04"]
                          ];
    scrollView.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    scrollView.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
//    scrollView.placeholder = [UIImage imageNamed:@"test"];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
}

#pragma mark - <XMGInifiteScrollViewDelegate>
- (void)inifiteScrollView:(XMGInifiteScrollView *)inifiteScrollView didClickImageAtIndex:(NSInteger)index
{
    NSLog(@"点击了第%zd个图片", index);
    
    if (index == 0) {
    
    }
}
@end
