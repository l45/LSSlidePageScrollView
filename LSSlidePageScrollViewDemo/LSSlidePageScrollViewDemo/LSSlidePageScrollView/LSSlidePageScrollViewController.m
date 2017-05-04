//
//  LSSlidePageScrollViewController.m
//  test20161130
//
//  Created by liu on 2017/5/3.
//  Copyright © 2017年 liu. All rights reserved.
//

#import "LSSlidePageScrollViewController.h"

@interface LSSlidePageScrollViewController ()

@end

@implementation LSSlidePageScrollViewController



#pragma mark - override
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addSlidePageScrollView];
    [self layoutSlidePageScrollView];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return false;
}

#pragma mark - private
- (void)addSlidePageScrollView {
    _slidePageScrollView = [[LSSlidePageScrollView alloc] initWithFrame:self.view.bounds];
    _slidePageScrollView.delegate = self;
    _slidePageScrollView.dataSource = self;
    _slidePageScrollView.shouldAutomaticallyForwardAppearanceMethods = true;
    [self.view addSubview:_slidePageScrollView];
}

- (void)layoutSlidePageScrollView {
    _slidePageScrollView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_slidePageScrollView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_slidePageScrollView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_slidePageScrollView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_slidePageScrollView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1 constant:0]];
}

#pragma mark - LSSlidePageScrollViewDataSource
- (NSInteger)numberOfPageViewOnSlidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView {
    return _viewControllers.count;
}

- (UIScrollView *)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView
       pageVerticalScrollViewForIndex:(NSInteger)index {
    UIViewController *vc = _viewControllers[index];
    if ([vc respondsToSelector:@selector(displayPageScrollViewWithSlidePageScrollViewController:)]) {
        return [(id<LSDisplayPageScrollViewDelegate>)vc displayPageScrollViewWithSlidePageScrollViewController:self];
    } else if ([vc.view isKindOfClass:UIScrollView.class]) {
        return (UIScrollView *)vc.view;
    }
    NSAssert(false, @"can not find a UIScrollView, you can follow LSDisplayPageScrollViewDelegate and return a UIScrollView");
    return (UIScrollView *)vc.view;
}

- (UIViewController *)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView
viewControllerForPageVerticalScrollViewAtIndex:(NSInteger)index {
    return _viewControllers[index];
}

#pragma mark - LSSlidePageScrollViewDelegate

@end
