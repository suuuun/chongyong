//
//  ViewController.m
//  yidong
//
//  Created by MAC on 16/8/12.
//  Copyright © 2016年 MAC. All rights reserved.
//

#import "ViewController.h"
#import "CustomSegmentControlView.h"
#import "CustomScrollView.h"

@interface ViewController ()

@property (nonatomic, strong) CustomSegmentControlView *headerView;
@property (nonatomic, strong) CustomScrollView *contentView;
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < 100; i ++) {
        [arr addObject:[NSString stringWithFormat:@"abc%02zi",i]];
    }
    
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.contentView];
    
    [self.headerView updateViewWithArray:arr];
    [self.contentView updateViewWithArray:arr];
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        
        [self.headerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(64, 0, 0, 0) excludingEdge:ALEdgeBottom];
        [self.headerView autoSetDimension:ALDimensionHeight toSize:50];
        
        [self.contentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.contentView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headerView];
    }
}

#pragma mark - getters and setters

-(CustomSegmentControlView *)headerView {
    if (_headerView == nil) {
        _headerView = [[CustomSegmentControlView alloc] initForAutoLayout];
        _headerView.normalColor = [UIColor grayColor];
        [_headerView setViewBorderWidth:1 Color:[UIColor lightGrayColor]];
        [_headerView handleClickBlock:^(CGFloat index, id value) {
            NSLog(@"%f  %@",index, value);
            [self.contentView moveToIndex:index animate:YES];
        }];
    }
    return _headerView;
}

-(CustomScrollView *)contentView {
    if (_contentView == nil) {
        _contentView = [[CustomScrollView alloc] initForAutoLayout];
        @weakify_self
        [_contentView handleOffsetBlock:^(CGFloat index) {
            @strongify_self
            [self.headerView moveToIndex:index animate:NO];
        }];
    }
    return _contentView;
}

@end
