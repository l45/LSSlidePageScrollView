//
//  UIScrollView+ty_swizzle.h
//  TYSlidePageScrollViewDemo
//
//  Created by tanyang on 15/7/23.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (LSSlidePageScrollView)

@property (nonatomic, assign) CGFloat minContentSizeHeight;
@property (nonatomic, assign) BOOL needResetContentOffset; // default true

@end
