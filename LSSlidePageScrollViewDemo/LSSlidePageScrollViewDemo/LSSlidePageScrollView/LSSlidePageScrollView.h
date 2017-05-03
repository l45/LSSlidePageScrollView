//
//  LSSlidePageScrollView.h
//  test20161130
//
//  Created by liu on 2017/5/3.
//  Copyright © 2017年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSBasePageTabbar.h"

NS_ASSUME_NONNULL_BEGIN

@class LSSlidePageScrollView;

typedef NS_ENUM(NSInteger, LSPageTabBarState) {
    LSPageTabBarStateStopOnTop,
    LSPageTabBarStateScrolling,
    LSPageTabBarStateStopOnBottom,
};

@protocol LSSlidePageScrollViewDataSource <NSObject>

@required

// num of pageViews
- (NSInteger)numberOfPageViewOnSlidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView;

// pageView need inherit UIScrollView (UITableview inherit it) ,and vertical scroll
- (UIScrollView *)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView pageVerticalScrollViewForIndex:(NSInteger)index;

@optional

// controller for view at index
- (nullable UIViewController *)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView viewControllerForPageVerticalScrollViewAtIndex:(NSInteger)index;

@end

@protocol LSSlidePageScrollViewDelegate <NSObject>

@optional

// vertical scroll any offset changes will call
- (void)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView verticalScrollViewDidScroll:(UIScrollView *)pageScrollView;

// pageTabBar vertical scroll and state
- (void)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView pageTabBarScrollOffset:(CGFloat)offset state:(LSPageTabBarState)state;

// horizen scroll to pageIndex, when index change will call
- (void)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView horizenScrollToPageIndex:(NSInteger)index;

// horizen scroll any offset changes will call
- (void)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView horizenScrollViewDidScroll:(UIScrollView *)scrollView;

// horizen scroll Begin Dragging
- (void)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView horizenScrollViewWillBeginDragging:(UIScrollView *)scrollView;

// horizen scroll called when scroll view grinds to a halt
- (void)slidePageScrollView:(LSSlidePageScrollView *)slidePageScrollView horizenScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@interface LSSlidePageScrollView : UIView

@property (nonatomic, weak, nullable)   id<LSSlidePageScrollViewDataSource> dataSource;
@property (nonatomic, weak, nullable)   id<LSSlidePageScrollViewDelegate> delegate;

@property (nonatomic, assign) BOOL headerViewScrollEnable; // default YES， header let to veritical scroll (header区域是否可以上下滑动)

@property (nonatomic, strong, nullable) UIView *headerView; // defult nil，don't forget set height
@property (nonatomic, assign) BOOL parallaxHeaderEffect; // def NO, Parallax effect (弹性视差效果)

@property (nonatomic, strong, nullable) UIView<LSBasePageTabbarProtocol> *pageTabbar; //defult nil
@property (nonatomic, assign) BOOL pageTabBarIsStopOnTop;  // default YES, is stop on top
@property (nonatomic, assign) CGFloat pageTabBarStopOnTopHeight; // default 0, bageTabBar stop on top height, if pageTabBarIsStopOnTop is NO ,this property is inValid

@property (nonatomic, strong, nullable) UIView *footerView; // defult nil

@property (nonatomic, assign, readonly) NSInteger curPageIndex; // defult 0

// 当滚动到scroll宽度的百分之多少 改变index
@property (nonatomic, assign) CGFloat changeToNextIndexWhenScrollToWidthOfPercent; // 0.0~0.1 default 0.5, when scroll to half of width, change to next index

/**
 default false, set true will auto call viewController of verticalScrollViews
 [viewWillAppear/viewDidAppear/viewWillDisappear/viewDidDisappear]
 to do this, you should override [shouldAutomaticallyForwardAppearanceMethods]
 of viewController of self, return false
 */
@property (nonatomic, assign) BOOL shouldAutomaticallyForwardAppearanceMethods;

- (void)reloadData;

- (void)scrollToPageIndex:(NSInteger)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
