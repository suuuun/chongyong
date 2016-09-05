//
//  CustomSegmentControlView.m
//  yidong
//
//  Created by MAC on 16/8/12.
//  Copyright © 2016年 MAC. All rights reserved.
//

#import "CustomSegmentControlView.h"

@interface CustomSegmentControlView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *animateView;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) NSLayoutConstraint *contentViewWidth;
@property (nonatomic, strong) NSLayoutConstraint *animateViewLeading;
@property (nonatomic, copy) CustomSegmentControlViewClickBlock block;
@property (nonatomic, assign) CGFloat selectedIndex;
@property (nonatomic, assign) CGFloat itemViewWidth;
@property (nonatomic, assign) CGFloat leftSpace;
@property (nonatomic, assign) CGFloat rightSpace;

//保存可见的视图
@property (nonatomic, strong) NSMutableSet *baseVisibleViews;
@property (nonatomic, strong) NSMutableSet *animateVisibleViews;
@property (nonatomic, strong) NSMutableSet *buttonVisibleViews;
//保存可重用的
@property (nonatomic, strong) NSMutableSet *baseReusedViews;
@property (nonatomic, strong) NSMutableSet *animateReusedViews;
@property (nonatomic, strong) NSMutableSet *buttonReusedViews;

@end

@implementation CustomSegmentControlView

-(instancetype)init {
    if (self = [super init]) {
        self.selectedIndex = 0;
        self.itemViewWidth = 60;
        self.leftSpace = 5;
        self.rightSpace = 5;
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.contentView];
        [self.contentView addSubview:self.baseView];
        [self.contentView addSubview:self.animateView];
        [self.contentView addSubview:self.buttonView];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

-(void)updateConstraints {
    [super updateConstraints];
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        
        [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self.contentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self.contentView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.scrollView];
        
        [self.baseView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self.buttonView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        [self.animateView autoSetDimension:ALDimensionWidth toSize:self.itemViewWidth];
        [self.animateView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.baseView];
        [self.animateView autoSetDimension:ALDimensionHeight toSize:25];
    }
}

-(void)handleClickBlock:(CustomSegmentControlViewClickBlock)block {
    self.block = block;
}

-(void)updateViewWithArray:(NSArray *)list {
    [self.baseView removeAllSubViews];
    [self.animateView removeAllSubViews];
    [self.buttonView removeAllSubViews];
    
    [self.baseVisibleViews removeAllObjects];
    [self.baseReusedViews removeAllObjects];
    [self.animateVisibleViews removeAllObjects];
    [self.animateReusedViews removeAllObjects];
    [self.buttonVisibleViews removeAllObjects];
    [self.buttonReusedViews removeAllObjects];
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObjectsFromArray:list];
    
    if (self.contentViewWidth) {
        [self.contentViewWidth autoRemove];
        self.contentViewWidth = nil;
    }
    
    self.contentViewWidth = [self.contentView autoSetDimension:ALDimensionWidth toSize:self.itemViewWidth * list.count + self.leftSpace + self.rightSpace];
    
    if (self.animateViewLeading) {
        [self.animateViewLeading autoRemove];
        self.animateViewLeading = nil;
    }
    
    self.animateViewLeading = [self.animateView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:self.leftSpace];
    
    [self showViews];
    
    [self setNeedsUpdateConstraints];
}

-(void)clickItem:(UIButton*)button {
    for (UIButton *itemView in self.buttonVisibleViews) {
        itemView.selected = NO;
    }
    button.selected = YES;

    if (self.block) {
        if (button.tag < self.dataSource.count) {
            id item = [self.dataSource objectAtIndex:button.tag];
            self.block(button.tag,item);
        }
    }
    
    [self moveToIndex:button.tag animate:YES];
}

#pragma mark - Private Method

- (void)showViews {
    
    // 获取当前处于显示范围内的view的索引
    CGFloat minX = self.scrollView.contentOffset.x;
    CGFloat maxX = self.scrollView.contentOffset.x + [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = self.itemViewWidth;
    
    NSInteger firstIndex = (NSInteger)floorf(minX / width);
    NSInteger lastIndex  = (NSInteger)floorf(maxX / width);
    
    // 处理越界的情况
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    
    if (lastIndex >= [self.dataSource count]) {
        lastIndex = [self.dataSource count] - 1;
    }
    
    // 回收不再显示的View
    {
        NSInteger viewIndex = 0;
        for (UIView *itemView in self.baseVisibleViews) {
            viewIndex = itemView.tag;
            // 不在显示范围内
            if (viewIndex < firstIndex || viewIndex > lastIndex) {
                [self.baseReusedViews addObject:itemView];
                [itemView removeFromSuperview];
            }
        }
        
        [self.baseVisibleViews minusSet:self.baseReusedViews];
    }
    
    {
        NSInteger viewIndex = 0;
        for (UIView *itemView in self.animateVisibleViews) {
            viewIndex = itemView.tag;
            // 不在显示范围内
            if (viewIndex < firstIndex || viewIndex > lastIndex) {
                [self.animateReusedViews addObject:itemView];
                [itemView removeFromSuperview];
            }
        }
        
        [self.animateVisibleViews minusSet:self.animateReusedViews];
    }
    
    {
        NSInteger viewIndex = 0;
        for (UIView *itemView in self.buttonVisibleViews) {
            viewIndex = itemView.tag;
            // 不在显示范围内
            if (viewIndex < firstIndex || viewIndex > lastIndex) {
                [self.buttonReusedViews addObject:itemView];
                [itemView removeFromSuperview];
            }
        }
        
        [self.buttonVisibleViews minusSet:self.buttonReusedViews];
    }
    
    // 是否需要显示新的视图
    {
        for (NSInteger index = firstIndex; index <= lastIndex; index++) {
            BOOL isShow = NO;
            
            for (UIView *itemView in self.baseVisibleViews) {
                if (itemView.tag == index) {
                    isShow = YES;
                }
            }
            
            if (!isShow) {
                [self showBaseLabelAtIndex:index];
            }
        }
    }
    
    {
        for (NSInteger index = firstIndex; index <= lastIndex; index++) {
            BOOL isShow = NO;
            
            for (UIView *itemView in self.animateVisibleViews) {
                if (itemView.tag == index) {
                    isShow = YES;
                }
            }
            
            if (!isShow) {
                [self showAnimateLabelAtIndex:index];
            }
        }
    }
    
    {
        for (NSInteger index = firstIndex; index <= lastIndex; index++) {
            BOOL isShow = NO;
            
            for (UIView *itemView in self.buttonVisibleViews) {
                if (itemView.tag == index) {
                    isShow = YES;
                }
            }
            
            if (!isShow) {
                [self showButtonAtIndex:index];
            }
        }
    }
}

// 显示一个view
- (void)showBaseLabelAtIndex:(NSInteger)index {
    UILabel *baseLabel = [self.baseReusedViews anyObject];
    
    if (baseLabel) {
        [self.baseReusedViews removeObject:baseLabel];
    } else {
        baseLabel = [[UILabel alloc] initForAutoLayout];
    }
    
    baseLabel.textColor = self.normalColor;
    baseLabel.textAlignment = NSTextAlignmentCenter;
    baseLabel.font = [UIFont systemFontOfSize:15];
    baseLabel.tag = index;
    
    [self.baseVisibleViews addObject:baseLabel];
    [self.baseView addSubview:baseLabel];
    
    [baseLabel.constraints autoRemoveConstraints];
    [baseLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:self.itemViewWidth * index + self.leftSpace];
    [baseLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [baseLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [baseLabel autoSetDimension:ALDimensionWidth toSize:self.itemViewWidth];
    
    if (index < self.dataSource.count) {
        NSString *item = [self.dataSource objectAtIndex:index];
        baseLabel.text = item;
    }
}

- (void)showAnimateLabelAtIndex:(NSInteger)index {
    UILabel *animateLabel = [self.animateReusedViews anyObject];
    
    if (animateLabel) {
        [self.animateReusedViews removeObject:animateLabel];
    } else {
        animateLabel = [[UILabel alloc] initForAutoLayout];
    }
    
    animateLabel.textColor = self.highlightedColor;
    animateLabel.textAlignment = NSTextAlignmentCenter;
    animateLabel.font = [UIFont systemFontOfSize:15];
    animateLabel.tag = index;
    
    [self.animateVisibleViews addObject:animateLabel];
    [self.animateView addSubview:animateLabel];
    
    [animateLabel.constraints autoRemoveConstraints];
    [animateLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.baseView withOffset:self.itemViewWidth * index + self.leftSpace];
    [animateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.baseView];
    [animateLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.baseView];
    [animateLabel autoSetDimension:ALDimensionWidth toSize:self.itemViewWidth];
    
    if (index < self.dataSource.count) {
        NSString *item = [self.dataSource objectAtIndex:index];
        animateLabel.text = item;
    }
}

- (void)showButtonAtIndex:(NSInteger)index {
    UIButton *itemView = [self.buttonReusedViews anyObject];
    
    if (itemView) {
        [self.buttonReusedViews removeObject:itemView];
    } else {
        itemView = [[UIButton alloc] initForAutoLayout];
        [itemView addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    itemView.tag = index;
    
    if (index == round(self.selectedIndex)) {
        itemView.selected = YES;
    }else {
        itemView.selected = NO;
    }
    
    [self.buttonVisibleViews addObject:itemView];
    [self.buttonView addSubview:itemView];
    
    [itemView.constraints autoRemoveConstraints];
    [itemView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:self.itemViewWidth * index + self.leftSpace];
    [itemView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [itemView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [itemView autoSetDimension:ALDimensionWidth toSize:self.itemViewWidth];
}

-(void)moveToIndex:(CGFloat)index animate:(BOOL)animate {
    self.selectedIndex = index;
    
    if (self.animateViewLeading) {
        [self.animateViewLeading autoRemove];
        self.animateViewLeading = nil;
    }
    self.animateViewLeading = [self.animateView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:self.itemViewWidth * index + self.leftSpace];
    
    if (animate) {
        [self updateConstraintsIfNeeded];
        @weakify_self
        [UIView animateWithDuration:0.3 animations:^{
            @strongify_self
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }else {
        [self setNeedsUpdateConstraints];
        
        CGFloat contentWidth = self.itemViewWidth * self.dataSource.count + self.leftSpace + self.rightSpace;
        CGFloat moveViewMinX = self.itemViewWidth * index + self.leftSpace;
        CGFloat minOffsetX = moveViewMinX + (self.itemViewWidth + self.rightSpace) - [[UIScreen mainScreen] bounds].size.width;
        CGFloat maxOffsetX = moveViewMinX - self.leftSpace;
        minOffsetX = MAX(minOffsetX, 0);
        maxOffsetX = MAX(maxOffsetX, 0);
        minOffsetX = MIN(minOffsetX, contentWidth - [[UIScreen mainScreen] bounds].size.width);
        maxOffsetX = MIN(maxOffsetX, contentWidth - [[UIScreen mainScreen] bounds].size.width);
        if (self.scrollView.contentOffset.x < minOffsetX) {
            [self.scrollView setContentOffset:CGPointMake(minOffsetX, 0) animated:NO];
        }else if (self.scrollView.contentOffset.x > maxOffsetX) {
            [self.scrollView setContentOffset:CGPointMake(maxOffsetX, 0) animated:NO];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showViews];
}

#pragma mark - getters and setters

-(UIColor *)normalColor {
    if (_normalColor == nil) {
        _normalColor = [UIColor blackColor];
    }
    return _normalColor;
}

-(UIColor *)highlightedColor {
    if (_highlightedColor == nil) {
        _highlightedColor = [UIColor whiteColor];
    }
    return _highlightedColor;
}

-(UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initForAutoLayout];
        _scrollView.pagingEnabled = NO;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    return _scrollView;
}

-(UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initForAutoLayout];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

-(UIView *)baseView {
    if (_baseView == nil) {
        _baseView = [[UIView alloc] initForAutoLayout];
        _baseView.backgroundColor = [UIColor clearColor];
    }
    return _baseView;
}

-(UIView *)animateView {
    if (_animateView == nil) {
        _animateView = [[UIView alloc] initForAutoLayout];
        _animateView.clipsToBounds = YES;
        _animateView.backgroundColor = [UIColor redColor];
        [_animateView setViewRadius:12];
    }
    return _animateView;
}

-(UIView *)buttonView {
    if (_buttonView == nil) {
        _buttonView = [[UIView alloc] initForAutoLayout];
        _buttonView.backgroundColor = [UIColor clearColor];
    }
    return _buttonView;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

-(NSMutableSet *)baseVisibleViews {
    if (_baseVisibleViews == nil) {
        _baseVisibleViews = [[NSMutableSet alloc] init];
    }
    return _baseVisibleViews;
}

-(NSMutableSet *)baseReusedViews {
    if (_baseReusedViews == nil) {
        _baseReusedViews = [[NSMutableSet alloc] init];
    }
    return _baseReusedViews;
}

-(NSMutableSet *)animateVisibleViews {
    if (_animateVisibleViews == nil) {
        _animateVisibleViews = [[NSMutableSet alloc] init];
    }
    return _animateVisibleViews;
}

-(NSMutableSet *)animateReusedViews {
    if (_animateReusedViews == nil) {
        _animateReusedViews = [[NSMutableSet alloc] init];
    }
    return _animateReusedViews;
}

-(NSMutableSet *)buttonVisibleViews {
    if (_buttonVisibleViews == nil) {
        _buttonVisibleViews = [[NSMutableSet alloc] init];
    }
    return _buttonVisibleViews;
}

-(NSMutableSet *)buttonReusedViews {
    if (_buttonReusedViews == nil) {
        _buttonReusedViews = [[NSMutableSet alloc] init];
    }
    return _buttonReusedViews;
}

@end
