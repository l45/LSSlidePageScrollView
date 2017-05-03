//
//  UIScrollView+ty_swizzle.m
//  TYSlidePageScrollViewDemo
//
//  Created by tanyang on 15/7/23.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "UIScrollView+LSSlidePageScrollView.h"
#import <objc/runtime.h>

@implementation UIScrollView (LSSlidePageScrollView)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self ty_swizzleMethodWithOrignalSel:@selector(setContentSize:) replacementSel:@selector(ty_setContentSize:)];
    });
}

- (CGFloat)minContentSizeHeight
{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setMinContentSizeHeight:(CGFloat)minContentSizeHeight
{
    objc_setAssociatedObject(self, @selector(minContentSizeHeight), @(minContentSizeHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needResetContentOffset
{
    id temp = objc_getAssociatedObject(self, _cmd);
    if (temp == nil) {
        return true;
    } else {
        return [temp boolValue];
    }
}

- (void)setNeedResetContentOffset:(BOOL)needResetContentOffset
{
    objc_setAssociatedObject(self, @selector(needResetContentOffset), @(needResetContentOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// replace method
- (void)ty_setContentSize:(CGSize)contentSize
{
    if (contentSize.height < self.minContentSizeHeight) {
        contentSize = CGSizeMake(contentSize.width, self.minContentSizeHeight);
    }
    [self ty_setContentSize:contentSize];
}

// exchange method
+ (BOOL)ty_swizzleMethodWithOrignalSel:(SEL)originalSel replacementSel:(SEL)replacementSel
{
    Method origMethod = class_getInstanceMethod(self, originalSel);
    Method replMethod = class_getInstanceMethod(self, replacementSel);
    
    if (!origMethod) {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), [self class]);
        return NO;
    }
    
    if (!replMethod) {
        NSLog(@"replace method %@ not found for class %@", NSStringFromSelector(replacementSel), [self class]);
        return NO;
    }
    
    if (class_addMethod(self, originalSel, method_getImplementation(replMethod), method_getTypeEncoding(replMethod)))
    {
        class_replaceMethod(self, replacementSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, replMethod);
    }
    return YES;
}

@end
