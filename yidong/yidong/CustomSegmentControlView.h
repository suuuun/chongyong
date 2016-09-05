//
//  CustomSegmentControlView.h
//  yidong
//
//  Created by MAC on 16/8/12.
//  Copyright © 2016年 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CustomSegmentControlViewClickBlock)(CGFloat index, id value);

@interface CustomSegmentControlView : UIView

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightedColor;

-(void)updateViewWithArray:(NSArray*)list;
-(void)handleClickBlock:(CustomSegmentControlViewClickBlock)block;
-(void)moveToIndex:(CGFloat)index animate:(BOOL)animate;

@end
