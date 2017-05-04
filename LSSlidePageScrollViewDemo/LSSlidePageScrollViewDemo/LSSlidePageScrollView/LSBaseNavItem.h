//
//  LSCustomNavbarView.h
//  LSSlidePageScrollViewDemo
//
//  Created by liu on 2017/5/4.
//  Copyright © 2017年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LSBaseNavItemProtorol <NSObject>

@required

/**
 note: max must > min, current maybe out of [min, max]
 */
- (void)adjustUIWithCurrent:(CGFloat)current max:(CGFloat)max min:(CGFloat)min;

@end

@interface LSCustomNavItemView : UIView <LSBaseNavItemProtorol>

- (void)adjustUIWithCurrent:(CGFloat)current max:(CGFloat)max min:(CGFloat)min;

@property (nonatomic, strong, readonly) UIButton *leftButton;
@property (nonatomic, strong, readonly) UIButton *rightButton;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, assign) UIEdgeInsets edgeInset;

@end

NS_ASSUME_NONNULL_END
