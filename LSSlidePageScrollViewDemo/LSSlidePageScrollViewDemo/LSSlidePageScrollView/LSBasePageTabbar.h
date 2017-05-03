//
//  LSBasePageTabbar.h
//  test20161130
//
//  Created by liu on 2017/5/3.
//  Copyright © 2017年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LSBasePageTabbarDelegate;

@protocol LSBasePageTabbarProtocol <NSObject>

@required

@property (nonatomic, weak, nullable) id<LSBasePageTabbarDelegate> delegate;
- (void)switchToPageAtIndex:(NSInteger)index;

@end

@protocol LSBasePageTabbarDelegate <NSObject>

@required

- (void)basePageTabbar:(id<LSBasePageTabbarProtocol>)tabbar clickedPageTabbarAtIndex:(NSInteger)index;

@end

@interface LSTitlePageTabbar : UIView <LSBasePageTabbarProtocol>

@property (nonatomic, weak, nullable) id<LSBasePageTabbarDelegate> delegate;
- (void)switchToPageAtIndex:(NSInteger)index;

@property (nonatomic, assign, readonly) NSInteger curIndex;

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *selectedTextFont;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;

@property (nonatomic, strong) UIColor *horIndicatorColor;
@property (nonatomic, assign) CGFloat horIndicatorHeight;
@property (nonatomic, assign) CGFloat horIndicatorSpacing;

@property (nonatomic, assign) UIEdgeInsets edgeInset;
@property (nonatomic, assign) CGFloat titleSpacing;

- (void)refreshUI;

- (instancetype)initWithTitleArray:(NSArray<NSString *> *)titleArray;

@end

NS_ASSUME_NONNULL_END
