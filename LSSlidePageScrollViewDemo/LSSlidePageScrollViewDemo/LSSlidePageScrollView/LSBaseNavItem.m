//
//  LSCustomNavbarView.m
//  LSSlidePageScrollViewDemo
//
//  Created by liu on 2017/5/4.
//  Copyright © 2017年 liu. All rights reserved.
//

#import "LSBaseNavItem.h"

@implementation LSCustomNavItemView

- (void)adjustUIWithCurrent:(CGFloat)current max:(CGFloat)max min:(CGFloat)min
{
    CGFloat slideRange = max - min;
    slideRange = (slideRange >= 60) ? 60 : slideRange;
    CGFloat slideCur = current - min;
    CGFloat ratio = slideCur / slideRange;
    ratio = ratio < 0 ? 0 : (ratio > 1 ? 1 : ratio);
    self.alpha = 1 - ratio;
}

#pragma mark - override
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self prepareUI];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self prepareUI];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width - _edgeInset.left - _edgeInset.right;
    CGFloat height = self.frame.size.height - _edgeInset.top - _edgeInset.bottom;
    
    _leftButton.frame = CGRectMake(_edgeInset.left,
                                   _edgeInset.top + (height - 40) * 0.5, 40, 40);
    _rightButton.frame = CGRectMake(self.frame.size.width - _edgeInset.right - 40,
                                    _edgeInset.top + (height - 40) * 0.5, 40, 40);
    _titleLabel.frame = CGRectMake(_edgeInset.left + 45,
                                   _edgeInset.top, width - 90, height);
}

#pragma mark - private
- (void)prepareUI
{
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:_titleLabel];
    
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftButton setImage:[UIImage imageNamed:@"back-hover"] forState:UIControlStateNormal];
    [self addSubview:_leftButton];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setImage:[UIImage imageNamed:@"share-hover"] forState:UIControlStateNormal];
    [self addSubview:_rightButton];
    
    _edgeInset = UIEdgeInsetsZero;
    
    self.backgroundColor = [UIColor orangeColor];
}

@end
