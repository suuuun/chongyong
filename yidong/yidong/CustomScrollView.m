//
//  CustomScrollView.m
//  yidong
//
//  Created by MAC on 16/8/12.
//  Copyright © 2016年 MAC. All rights reserved.
//

#import "CustomScrollView.h"

@interface CustomScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) NSLayoutConstraint *contentViewWidth;
@property (nonatomic, copy) CustomScrollViewOffsetBlock block;

@property (nonatomic, strong) NSMutableSet *visibleViews;//保存可见的视图
@property (nonatomic, strong) NSMutableSet *reusedViews;//保存可重用的
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGFloat itemViewWidth;
@property (nonatomic, assign) BOOL draggingView;

@end

@implementation CustomScrollView

-(instancetype)init {
    if (self = [super init]) {
        self.selectedIndex = 0;
        self.itemViewWidth = [[UIScreen mainScreen] bounds].size.width;
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.contentView];
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
    }
}

-(void)updateViewWithArray:(NSArray*)list {
    [self.contentView removeAllSubViews];
    [self.dataSource removeAllObjects];
    [self.visibleViews removeAllObjects];
    [self.reusedViews removeAllObjects];
    [self.dataSource addObjectsFromArray:list];
    
    if (self.contentViewWidth) {
        [self.contentViewWidth autoRemove];
        self.contentViewWidth = nil;
    }
    self.contentViewWidth = [self.contentView autoSetDimension:ALDimensionWidth toSize:self.itemViewWidth * list.count];
        
    [self showViews];
}

-(void)moveToIndex:(CGFloat)index animate:(BOOL)animate {
    self.draggingView = NO;
    [self.scrollView setContentOffset:CGPointMake(index * self.itemViewWidth, 0) animated:animate];
}

-(void)handleOffsetBlock:(CustomScrollViewOffsetBlock)block {
    self.block = block;
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
    NSInteger viewIndex = 0;
    for (UIView *itemView in self.visibleViews) {
        viewIndex = itemView.tag;
        // 不在显示范围内
        if (viewIndex < firstIndex || viewIndex > lastIndex) {
            [self.reusedViews addObject:itemView];
            [itemView removeFromSuperview];
        }
    }
    
    [self.visibleViews minusSet:self.reusedViews];
    
    // 是否需要显示新的视图
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        BOOL isShow = NO;
        
        for (UIView *itemView in self.visibleViews) {
            if (itemView.tag == index) {
                isShow = YES;
            }
        }
        
        if (!isShow) {
            [self showViewAtIndex:index];
        }
    }
}

// 显示一个view
- (void)showViewAtIndex:(NSInteger)index {
    UILabel *itemView = [self.reusedViews anyObject];
    
    if (itemView) {
        [self.reusedViews removeObject:itemView];
    } else {
        itemView = [[UILabel alloc] initForAutoLayout];
    }
    
    itemView.textColor = [UIColor blackColor];
    itemView.textAlignment = NSTextAlignmentCenter;
    itemView.font = [UIFont systemFontOfSize:30];
    itemView.backgroundColor = [UIColor colorWithRed:(arc4random()%255/255.0) green:(arc4random()%255/255.0) blue:(arc4random()%255/255.0) alpha:1.0];
    itemView.tag = index;
    
    [self.visibleViews addObject:itemView];
    [self.contentView addSubview:itemView];
    
    [itemView.constraints autoRemoveConstraints];
    [itemView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:self.itemViewWidth * index];
    [itemView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [itemView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [itemView autoSetDimension:ALDimensionWidth toSize:self.itemViewWidth];
    
    if (index < self.dataSource.count) {
        NSString *item = [self.dataSource objectAtIndex:index];
        itemView.text = item;
    }
}

-(void)checkMoved {
    if (self.draggingView) {
        if (self.block) {
            self.block(self.scrollView.contentOffset.x/self.itemViewWidth);
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showViews];
    [self checkMoved];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.draggingView = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.draggingView = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.draggingView = NO;
}

#pragma mark - getters and setters

-(UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initForAutoLayout];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
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

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableSet *)visibleViews {
    if (_visibleViews == nil) {
        _visibleViews = [[NSMutableSet alloc] init];
    }
    return _visibleViews;
}

- (NSMutableSet *)reusedViews {
    if (_reusedViews == nil) {
        _reusedViews = [[NSMutableSet alloc] init];
    }
    return _reusedViews;
}


@end
