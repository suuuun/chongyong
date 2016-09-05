//
//  CategoryUtil.h
//  daoweifvh
//
//  Created by MAC on 14/11/18.
//  Copyright (c) 2014年 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UINavigationItem (FixSpace)

-(void)setLeftCustomViewBarButtonItemAndFixSpace:(UIBarButtonItem*)barButtonItem;
-(void)setRightCustomViewBarButtonItemAndFixSpace:(UIBarButtonItem*)barButtonItem;
-(void)setBackBarButtonItemWithTitle:(NSString*)title  target:(id)target action:(SEL)action;

@end

@interface NSString(EncodingDecoding)
+(NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding;
+(NSString*)stringWithUTF8EncodingData:(NSData*)data;
-(NSString*)URLEncodedString;
-(NSString*)URLDecodedString;
+(NSString*)MD5String:(NSString*)str;
+(NSInteger)lengthOfString:(NSString*)str;

@end

@interface NSString(DecimalNumber)
/**
 *格式化保留两位小数（不保留0）
 */
+(NSString *)floatAccurateToTwoDecimalPlaces:(float)value;
/**
 *格式化保留两位小数
 */
+(NSString *)floatAccurateToTwoDecimalPlaces:(float)value ignoreZero:(BOOL)ignoreZero;
/**
 *格式化保留两位小数（不保留0）
 */
+(NSString *)stringAccurateToTwoDecimalPlaces:(NSString*)value;
/**
 *格式化保留两位小数
 */
+(NSString *)stringAccurateToTwoDecimalPlaces:(NSString*)value ignoreZero:(BOOL)ignoreZero;
/**
 *加
 */
+(NSString*)decimalNumberAddWithOne:(NSString*)oneValue Two:(NSString*)twoValue;
/**
 *减
 */
+(NSString*)decimalNumberSubtractWithOne:(NSString*)oneValue Two:(NSString*)twoValue;
/**
 *除
 */
+(NSString*)decimalNumberDivideWithOne:(NSString*)oneValue Two:(NSString*)twoValue;
/**
 *乘
 */
+(NSString*)decimalNumberMutiplyWithOne:(NSString*)oneValue Two:(NSString*)twoValue;
/**
 *对比两个数字
 */
+(NSComparisonResult)decimalNumberCompareWithOne:(NSString*)oneValue Two:(NSString*)twoValue;

@end

@interface NSString (BankId)
-(NSString *)normalNumToBankNum;
-(NSString *)bankNumToNormalNum;

@end

@interface NSString (LabelLines)
- (NSArray *)getSeparatedLinesWithWidth:(CGFloat)width font:(UIFont*)font;
@end

@interface UILabel (LineNumber)
-(NSInteger)textLineNumber;
@end

@interface NSDictionary (ResponseAnalyze)
-(id)analyzeJson;
@end


@interface UIImage (Color)
+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
-(UIImage*)partImageInRect:(CGRect)rect;
-(void)saveToDocumentWithName:(NSString*)imageName;
- (UIImage*)scaledToSize:(CGSize)newSize;
+(UIImage *)compressImageWith:(UIImage *)image;
@end

@interface UIView (Border)
-(void)setViewBorderWidth:(float)width Color:(UIColor*)color Radius:(float)radius;
-(void)setViewRadius:(float)radius;
-(void)setViewBorderWidth:(float)width Color:(UIColor *)color;
-(void)removeAllSubViews;
-(void)removeSubViewWithTag:(NSInteger)tag;
- (void)addBottomBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addLeftBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addRightBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addBorderWithColor:(UIColor *)color andFrame:(CGRect) frame;
-(void)addShadow;
@end

@interface UIView (findFirstResponder)

-(UIView*)findFirstResponderBeneathView;
-(void)disableScrollsToTopPropertyOnAllSubviews;

@end

@interface UITextField (keyBoardCustomView)
-(void)setupKeyBoardCustomView;

@end

@interface UITextView (keyBoardCustomView)
-(void)setupKeyBoardCustomView;

@end

@interface UITableView (HideCellLine)
- (void)setExtraCellLineHidden;
@end

typedef void(^UIAlertViewClickBlock)(UIAlertView *alertView, NSInteger btnIndex);
@interface UIAlertView (Block)
-(void) handlerClickedButton:(UIAlertViewClickBlock)aBlock;
@end

typedef void (^ActionBlock)();
@interface UIButton(Block)
- (void) handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;
@end
