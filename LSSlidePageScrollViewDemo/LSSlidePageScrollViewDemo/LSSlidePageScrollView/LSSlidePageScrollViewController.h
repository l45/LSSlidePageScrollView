//
//  LSSlidePageScrollViewController.h
//  test20161130
//
//  Created by liu on 2017/5/3.
//  Copyright © 2017年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSlidePageScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@class LSSlidePageScrollViewController;

@protocol LSDisplayPageScrollViewDelegate <NSObject>

@optional

- (UIScrollView *)displayPageScrollViewWithSlidePageScrollViewController:(LSSlidePageScrollViewController *)slidePageScrollViewController;

@end

@interface LSSlidePageScrollViewController : UIViewController <LSSlidePageScrollViewDataSource, LSSlidePageScrollViewDelegate>

@property (nonatomic, strong, readonly) LSSlidePageScrollView *slidePageScrollView;

@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

@end

NS_ASSUME_NONNULL_END
