//
//  CustomScrollView.h
//  yidong
//
//  Created by MAC on 16/8/12.
//  Copyright © 2016年 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CustomScrollViewOffsetBlock)(CGFloat index);

@interface CustomScrollView : UIView

-(void)handleOffsetBlock:(CustomScrollViewOffsetBlock)block;
-(void)updateViewWithArray:(NSArray*)list;
-(void)moveToIndex:(CGFloat)index animate:(BOOL)animate;

@end
