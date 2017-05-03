//
//  LSBasePageTabbar.m
//  test20161130
//
//  Created by liu on 2017/5/3.
//  Copyright © 2017年 liu. All rights reserved.
//

#import "LSBasePageTabbar.h"

@interface LSTitlePageTabbar ()

@property (nonatomic, strong) NSArray<NSString *> *titleArray;
@property (nonatomic, strong) NSArray<UILabel *> *labelArray;
@property (nonatomic, strong) UIView *horIndicator;

@end

@implementation LSTitlePageTabbar

- (instancetype)initWithTitleArray:(NSArray<NSString *> *)titleArray {
    self = [super init];
    NSAssert(titleArray.count > 0, @"count of titleArray must > 0");
    self.titleArray = titleArray.copy;
    [self prepareUI];
    [self refreshUI];
    return self;
}

- (void)switchToPageAtIndex:(NSInteger)index {
    if (index == _curIndex) {
        return;
    }
    [self switchToPage:index];
}

- (void)refreshUI {
    _horIndicator.backgroundColor = _horIndicatorColor;
    
    [_labelArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:_titleArray.count];
    [_titleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger index, BOOL * _Nonnull stop) {
        UILabel *label = [UILabel new];
        label.text = title;
        label.tag = index;
        label.textColor = _textColor;
        label.font = _textFont;
        label.textAlignment = NSTextAlignmentCenter;
        [mArr addObject:label];
        [self addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapLabel:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = true;
        
        if (_curIndex == index) {
            label.textColor = _selectedTextColor;
            label.font = _selectedTextFont;
        }
    }];
    _labelArray = mArr.copy;
    
    [self bringSubviewToFront:_horIndicator];
    
    [self setNeedsLayout];
}

#pragma mark - override
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat labelWidth = (self.frame.size.width - _edgeInset.left - _edgeInset.right + _titleSpacing) / _labelArray.count - _titleSpacing;
    CGFloat labelHeight = self.frame.size.height - _edgeInset.top - _edgeInset.bottom;
    
    [_labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(obj.tag * (labelWidth + _titleSpacing) + _edgeInset.left, _edgeInset.top, labelWidth, labelHeight);
    }];
    
    _horIndicator.frame = CGRectMake(_curIndex * (labelWidth + _titleSpacing) + _edgeInset.left + _horIndicatorSpacing, self.frame.size.height - _horIndicatorHeight, labelWidth - _horIndicatorSpacing * 2, _horIndicatorHeight);
}

#pragma mark - private
- (void)prepareUI {
    _curIndex = 0;
    
    _textFont = [UIFont systemFontOfSize:16];
    _selectedTextFont = [UIFont systemFontOfSize:19];
    
    _textColor = [UIColor darkTextColor];
    _selectedTextColor = [UIColor redColor];
    
    _horIndicator = [UIView new];
    _horIndicatorColor = [UIColor redColor];
    _horIndicatorHeight = 2;
    _horIndicatorSpacing = 0;
    
    _edgeInset = UIEdgeInsetsZero;
    _titleSpacing = 0;
    
    [self addSubview:_horIndicator];
}

- (void)switchToPage:(NSInteger)index {
    UILabel *curLabel = _labelArray[_curIndex];
    curLabel.font = _textFont;
    curLabel.textColor = _textColor;
    
    UILabel *label = _labelArray[index];
    label.font = _selectedTextFont;
    label.textColor = _selectedTextColor;
    
    CGFloat temp = (self.frame.size.width - _edgeInset.left - _edgeInset.right + _titleSpacing) / _labelArray.count;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAllowUserInteraction&UIViewAnimationCurveEaseInOut animations:^{
        _horIndicator.transform = CGAffineTransformMakeTranslation(temp*index, 0);
    } completion:nil];
    
    _curIndex = index;
}

- (void)userTapLabel:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag;
    if (index == _curIndex) {
        return;
    }
    [self switchToPage:index];
    if ([self.delegate respondsToSelector:@selector(basePageTabbar:clickedPageTabbarAtIndex:)]) {
        [self.delegate basePageTabbar:self clickedPageTabbarAtIndex:index];
    }
}

@end
