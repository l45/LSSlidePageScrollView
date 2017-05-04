//
//  LSSlidePageScrollView.m
//  test20161130
//
//  Created by liu on 2017/5/3.
//  Copyright © 2017年 liu. All rights reserved.
//

#import "LSSlidePageScrollView.h"
#import "UIScrollView+LSSlidePageScrollView.h"

#define horScrollViewCellReuse @"horScrollViewCellReuse"

@interface LSSlidePageScrollView () <LSBasePageTabbarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *horScrollView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIView *headerContentView;

@property (nonatomic, strong) NSLayoutConstraint *headerContentYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *headerContentHeightConstraint;

@property (nonatomic, strong) UIPanGestureRecognizer *headerContentPanGusture;

@property (nonatomic, assign) CGFloat headerContentViewHeight;
@property (nonatomic, assign) CGFloat pageScrollViewOffsetY;

@property (nonatomic, strong) NSHashTable *hashTable;
@property (nonatomic, assign) CGFloat beginHeaderContentY;

@end

@implementation LSSlidePageScrollView

- (void)reloadData
{
    [self resetPropertys];
    
    [self updateHeaderContentView];
    [self layoutHeaderContentView];
    
    [self updateNavItem];
    [self layoutNavItem];
    
    [self updateFooterView];
    [self layoutFooterView];
    
    [self updatePageViews];
    [self layoutPageViews];
    
    [self bringSubviewToFront:_headerContentView];
    if (_navItem != nil) {
        [self bringSubviewToFront:_navItem];
    }
    
    [self addPageViewKeyPathOffsetWithOldIndex:-1 newIndex:_curPageIndex];
}

- (void)scrollToPageIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger number = [_dataSource numberOfPageViewOnSlidePageScrollView:self];
    if (index < 0) {
        index = 0;
    } else if (index >= number) {
        index = number - 1;
    }
    [_horScrollView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                           atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                   animated:animated];
}

#pragma mark - override
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setPropertys];
    [self addHorScrollView];
    [self addHeaderContentView];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setPropertys];
    [self addHorScrollView];
    [self addHeaderContentView];
    return self;
}

- (void)dealloc
{
    for (UIScrollView *view in _hashTable) {
        [view removeObserver:self forKeyPath:@"contentOffset" context:nil];
    }
}

#pragma mark - private
- (void)setPropertys
{
    _curPageIndex = 0;
    _headerViewScrollEnable = true;
    _pageTabBarStopOnTopHeight = 0;
    _pageTabBarIsStopOnTop = true;
    _changeToNextIndexWhenScrollToWidthOfPercent = 0.5;
    _shouldAutomaticallyForwardAppearanceMethods = false;
}

- (void)addHorScrollView
{
    _flowLayout = [UICollectionViewFlowLayout new];
    _flowLayout.itemSize = CGSizeMake(50, 50);
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout.minimumLineSpacing = 0;
    
    _horScrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    _horScrollView.backgroundColor = [UIColor whiteColor];
    _horScrollView.pagingEnabled = true;
    _horScrollView.bounces = false;
    _horScrollView.showsHorizontalScrollIndicator = false;
    [_horScrollView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:horScrollViewCellReuse];
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10) {
        _horScrollView.prefetchingEnabled = false;
    }
}

- (void)addHeaderContentView
{
    _headerContentView = [[UIView alloc] init];
    [self addSubview:_headerContentView];
    
    _headerContentPanGusture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(headerContentPanGustureDidPan:)];
    [_headerContentView addGestureRecognizer:_headerContentPanGusture];
    _headerContentPanGusture.delegate = self;
}

- (void)resetPropertys
{
    for (UIScrollView *view in _hashTable) {
        [view removeObserver:self forKeyPath:@"contentOffset" context:nil];
    }
    
    [_navItem removeFromSuperview];
    [_headerView removeFromSuperview];
    [_pageTabbar removeFromSuperview];
    _pageTabbar.delegate = nil;
    [_footerView removeFromSuperview];
    
    [_horScrollView removeFromSuperview];
    _horScrollView.delegate = nil;
    _horScrollView.dataSource = nil;
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstItem == _headerContentView || constraint.firstItem == _horScrollView) {
            [self removeConstraint:constraint];
        }
    }
}

- (void)updateHeaderContentView
{
    if (_headerView != nil) {
        [_headerContentView addSubview:_headerView];
    }
    if (_pageTabbar != nil) {
        _pageTabbar.delegate = self;
        [_headerContentView addSubview:_pageTabbar];
    }
}

- (void)layoutHeaderContentView
{
    _headerContentView.translatesAutoresizingMaskIntoConstraints = false;
    _headerContentYConstraint = [NSLayoutConstraint constraintWithItem:_headerContentView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1 constant:0];
    [self addConstraint:_headerContentYConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerContentView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerContentView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1 constant:0]];
    
    _headerContentViewHeight = _headerView.frame.size.height + _pageTabbar.frame.size.height;
    NSLayoutConstraint *heightConstraint = nil;
    for (NSLayoutConstraint *constraint in _headerContentView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            break;
        }
    }
    if (heightConstraint == nil) {
        heightConstraint = [NSLayoutConstraint constraintWithItem:_headerContentView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:_headerContentViewHeight];
        [_headerContentView addConstraint:heightConstraint];
    } else {
        heightConstraint.constant = _headerContentViewHeight;
    }
    _headerContentHeightConstraint = heightConstraint;
    
    if (_headerView != nil) {
        _headerView.translatesAutoresizingMaskIntoConstraints = false;
        [_headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:_headerView
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_headerContentView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1 constant:0]];
        [_headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:_headerView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_headerContentView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1 constant:0]];
        [_headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:_headerView
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_headerContentView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1 constant:0]];
        
        NSLayoutConstraint *heightConstraint = nil;
        for (NSLayoutConstraint *constraint in _headerView.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                heightConstraint = constraint;
                break;
            }
        }
        if (heightConstraint == nil) {
            heightConstraint = [NSLayoutConstraint constraintWithItem:_headerView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1
                                                             constant:_headerView.frame.size.height];
            [_headerView addConstraint:heightConstraint];
        } else {
            heightConstraint.constant = _headerView.frame.size.height;
        }
    }
    
    if (_pageTabbar != nil) {
        _pageTabbar.translatesAutoresizingMaskIntoConstraints = false;
        [_headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:_pageTabbar
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_headerContentView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1 constant:0]];
        [_headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:_pageTabbar
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_headerContentView
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1 constant:0]];
        [_headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:_pageTabbar
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_headerContentView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1 constant:0]];
        
        NSLayoutConstraint *heightConstraint = nil;
        for (NSLayoutConstraint *constraint in _pageTabbar.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                heightConstraint = constraint;
                break;
            }
        }
        if (heightConstraint == nil) {
            heightConstraint = [NSLayoutConstraint constraintWithItem:_pageTabbar
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1
                                                             constant:_pageTabbar.frame.size.height];
            [_pageTabbar addConstraint:heightConstraint];
        } else {
            heightConstraint.constant = _pageTabbar.frame.size.height;
        }
    }
}

- (void)updateNavItem
{
    if (_navItem != nil) {
        [self addSubview:_navItem];
    }
}

- (void)layoutNavItem
{
    if (_navItem == nil) {
        return;
    }
    _navItem.translatesAutoresizingMaskIntoConstraints = false;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_navItem
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_navItem
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_navItem
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1 constant:0]];
    
    NSLayoutConstraint *heightConstraint = nil;
    for (NSLayoutConstraint *constraint in _navItem.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            break;
        }
    }
    if (heightConstraint == nil) {
        [_navItem addConstraint:[NSLayoutConstraint constraintWithItem:_navItem
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:_navItem.frame.size.height]];
    } else {
        heightConstraint.constant = _navItem.frame.size.height;
    }
}

- (void)updateFooterView
{
    if (_footerView != nil) {
        [self addSubview:_footerView];
    }
}

- (void)layoutFooterView
{
    if (_footerView == nil) {
        return;
    }
    _footerView.translatesAutoresizingMaskIntoConstraints = false;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_footerView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_footerView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_footerView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1 constant:0]];
    
    NSLayoutConstraint *heightConstraint = nil;
    for (NSLayoutConstraint *constraint in _footerView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            break;
        }
    }
    if (heightConstraint == nil) {
        [_footerView addConstraint:[NSLayoutConstraint constraintWithItem:_footerView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:_footerView.frame.size.height]];
    } else {
        heightConstraint.constant = _footerView.frame.size.height;
    }
}

- (void)updatePageViews
{
    [self addSubview:_horScrollView];
    _horScrollView.delegate = self;
    _horScrollView.dataSource = self;
}

- (void)layoutPageViews
{
    _horScrollView.translatesAutoresizingMaskIntoConstraints = false;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_horScrollView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_horScrollView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_horScrollView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    
    if (_footerView != nil) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_horScrollView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_footerView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1 constant:0]];
        _flowLayout.itemSize = CGSizeMake(self.frame.size.width,
                                          self.frame.size.height - _footerView.frame.size.height);
    } else {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_horScrollView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1 constant:0]];
        _flowLayout.itemSize = self.frame.size;
    }
}

- (void)pageScrollViewDidScroll:(UIScrollView *)pageScrollView
           changeOtherPageViews:(BOOL)isNeedChange
{
    if ([self.delegate respondsToSelector:@selector(slidePageScrollView:verticalScrollViewDidScroll:)]) {
        [self.delegate slidePageScrollView:self verticalScrollViewDidScroll:pageScrollView];
    }
    
    CGFloat pageTabBarHeight = CGRectGetHeight(_pageTabbar.frame);

    NSInteger pageTabBarIsStopOnTop = _pageTabBarStopOnTopHeight;
    if (!_pageTabBarIsStopOnTop) {
        pageTabBarIsStopOnTop = - pageTabBarHeight;
    }

    CGFloat offsetY = pageScrollView.contentOffset.y;
    if ([self.navItem respondsToSelector:@selector(adjustUIWithCurrent:max:min:)]) {
        [self.navItem adjustUIWithCurrent:-offsetY max:_headerContentViewHeight
                                      min:pageTabBarHeight + pageTabBarIsStopOnTop];
    }
    
    if (offsetY <= -_headerContentViewHeight) {
        // headerContentView full show
        if (_headerContentYConstraint.constant != 0) {
            _headerContentYConstraint.constant = 0;
            if ([self.delegate respondsToSelector:@selector(slidePageScrollView:pageTabBarScrollOffset:state:)]) {
                [self.delegate slidePageScrollView:self pageTabBarScrollOffset:offsetY
                                             state:LSPageTabBarStateStopOnBottom];
            }
        }
        if (_parallaxHeaderEffect) {
            _headerContentHeightConstraint.constant = -offsetY;
        }
    }
    else if (offsetY < -pageTabBarHeight - pageTabBarIsStopOnTop) {
        // scroll headerContentView
        if (_parallaxHeaderEffect && _headerContentHeightConstraint.constant != _headerContentViewHeight) {
            _headerContentHeightConstraint.constant = _headerContentViewHeight;
        }
        _headerContentYConstraint.constant = -(offsetY+_headerContentViewHeight);

        UIScrollView *view = [_dataSource slidePageScrollView:self pageVerticalScrollViewForIndex:_curPageIndex];
        view.scrollIndicatorInsets = UIEdgeInsetsMake(-offsetY, 0, 0, 0);
        
        if ([self.delegate respondsToSelector:@selector(slidePageScrollView:pageTabBarScrollOffset:state:)]) {
            [self.delegate slidePageScrollView:self pageTabBarScrollOffset:offsetY
                                         state:LSPageTabBarStateScrolling];
        }
    }
    else {
        // pageTabBar on the top
        if (_parallaxHeaderEffect && _headerContentHeightConstraint.constant != _headerContentViewHeight) {
            _headerContentHeightConstraint.constant = _headerContentViewHeight;
        }

        if (_headerContentYConstraint.constant != -_headerContentViewHeight+pageTabBarHeight + pageTabBarIsStopOnTop) {
            _headerContentYConstraint.constant = -_headerContentViewHeight+pageTabBarHeight + pageTabBarIsStopOnTop;

            if ([self.delegate respondsToSelector:@selector(slidePageScrollView:pageTabBarScrollOffset:state:)]) {
                [self.delegate slidePageScrollView:self pageTabBarScrollOffset:offsetY
                                             state:LSPageTabBarStateStopOnTop];
            }
        }
    }
}

- (void)addPageViewKeyPathOffsetWithOldIndex:(NSInteger)oldIndex
                                    newIndex:(NSInteger)newIndex
{
    if (oldIndex == newIndex) {
        return;
    }
    NSInteger number = [self.dataSource numberOfPageViewOnSlidePageScrollView:self];
    if (oldIndex >= 0 && oldIndex < number) {
        UIScrollView *temp = [self.dataSource slidePageScrollView:self pageVerticalScrollViewForIndex:oldIndex];
        if ([self.hashTable containsObject:temp]) {
            [self.hashTable removeObject:temp];
            [temp removeObserver:self forKeyPath:@"contentOffset" context:nil];
        }
    }
    if (newIndex >= 0 && newIndex < number) {
        UIScrollView *temp = [self.dataSource slidePageScrollView:self pageVerticalScrollViewForIndex:newIndex];
        if (![self.hashTable containsObject:temp]) {
            [self.hashTable addObject:temp];
            [temp addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"] && [object isKindOfClass:UIScrollView.class]) {
        [self pageScrollViewDidScroll:object changeOtherPageViews:false];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)automaticallyForwardAppearanceMethods:(BOOL)show index:(NSInteger)index
{
    if (!_shouldAutomaticallyForwardAppearanceMethods) {
        return;
    }
    UIViewController *vc = nil;
    if ([self.dataSource respondsToSelector:@selector(slidePageScrollView:viewControllerForPageVerticalScrollViewAtIndex:)]) {
        vc = [self.dataSource slidePageScrollView:self viewControllerForPageVerticalScrollViewAtIndex:index];
    }
    if (vc == nil) {
        return;
    }
    [vc beginAppearanceTransition:show animated:true];
    [vc endAppearanceTransition];
}

- (void)headerContentPanGustureDidPan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        _beginHeaderContentY = _headerContentView.frame.origin.y;
    }
    
    CGFloat translationY = [pan translationInView:self].y;
    CGFloat temp = translationY + _beginHeaderContentY;
    if (temp > 0) {
        temp = 0;
    }
    CGFloat pageTabBarHeight = CGRectGetHeight(_pageTabbar.frame);
    CGFloat headerViewHeight = CGRectGetHeight(_headerView.frame);
    NSInteger pageTabBarIsStopOnTop = _pageTabBarStopOnTopHeight;
    if (!_pageTabBarIsStopOnTop) {
        pageTabBarIsStopOnTop = - pageTabBarHeight;
    }
    if (temp < pageTabBarIsStopOnTop - headerViewHeight) {
        temp = pageTabBarIsStopOnTop - headerViewHeight;
    }
    UIScrollView *cur = [_dataSource slidePageScrollView:self pageVerticalScrollViewForIndex:_curPageIndex];
    cur.contentOffset = CGPointMake(0, -temp-pageTabBarHeight-headerViewHeight);
}

#pragma mark - LSBasePageTabbarDelegate
- (void)basePageTabbar:(id<LSBasePageTabbarProtocol>)tabbar
clickedPageTabbarAtIndex:(NSInteger)index
{
    [self scrollToPageIndex:index animated:false];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [_dataSource numberOfPageViewOnSlidePageScrollView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:horScrollViewCellReuse
                                                                           forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIScrollView *view = [self.dataSource slidePageScrollView:self
                               pageVerticalScrollViewForIndex:indexPath.item];
    [cell.contentView addSubview:view];
    view.frame = cell.contentView.bounds;
    
    CGFloat pageTabBarHeight = CGRectGetHeight(_pageTabbar.frame);
    CGFloat pageTabBarIsStopOnTop = _pageTabBarStopOnTopHeight;
    if (!_pageTabBarIsStopOnTop) {
        pageTabBarIsStopOnTop = - pageTabBarHeight;
    }
    CGPoint contentOffset = view.contentOffset;
    CGFloat maxY = CGRectGetMaxY(_headerContentView.frame);
    if (view.needResetContentOffset || (maxY > pageTabBarHeight + pageTabBarIsStopOnTop) || contentOffset.y < -maxY) {
        contentOffset.y = -maxY;
    }
    view.needResetContentOffset = false;
    
    view.minContentSizeHeight = cell.contentView.bounds.size.height - pageTabBarHeight - pageTabBarIsStopOnTop;
    
    view.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.headerContentView.frame), 0, 0, 0);
    view.contentOffset = contentOffset;
    view.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.headerContentView.frame), 0, 0, 0);
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(slidePageScrollView:horizenScrollViewDidScroll:)]) {
        [self.delegate slidePageScrollView:self horizenScrollViewDidScroll:scrollView];
    }
    
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame) +
                                  _changeToNextIndexWhenScrollToWidthOfPercent);
    NSInteger number = [_dataSource numberOfPageViewOnSlidePageScrollView:self];
    
    if (_curPageIndex != index) {
        if (index >= number) {
            index = number-1;
        }
        if (index < 0) {
            index = 0;
        }

        [self addPageViewKeyPathOffsetWithOldIndex:_curPageIndex newIndex:index];
        _curPageIndex = index;

        if (_pageTabbar) {
            [_pageTabbar switchToPageAtIndex:_curPageIndex];
        }
        if ([self.delegate respondsToSelector:@selector(slidePageScrollView:horizenScrollToPageIndex:)]) {
            [self.delegate slidePageScrollView:self horizenScrollToPageIndex:_curPageIndex];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(slidePageScrollView:horizenScrollViewWillBeginDragging:)]) {
        [self.delegate slidePageScrollView:self horizenScrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(slidePageScrollView:horizenScrollViewDidEndDecelerating:)]) {
        [self.delegate slidePageScrollView:self horizenScrollViewDidEndDecelerating:scrollView];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return false;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self automaticallyForwardAppearanceMethods:true index:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self automaticallyForwardAppearanceMethods:false index:indexPath.item];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _headerContentPanGusture) {
        CGPoint translation = [_headerContentPanGusture translationInView:self];
        if (translation.y == 0 || ABS(translation.x/translation.y) >= 1) {
            return false;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - set/get
- (NSHashTable *)hashTable
{
    if (_hashTable == nil) {
        _hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _hashTable;
}

@end
