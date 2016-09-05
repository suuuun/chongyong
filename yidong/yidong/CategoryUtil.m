//
//  CategoryUtil.m
//  daoweifvh
//
//  Created by MAC on 14/11/18.
//  Copyright (c) 2014年 MAC. All rights reserved.
//

#import "CategoryUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#include <zlib.h>
#import <objc/runtime.h>
#import <CoreText/CoreText.h>

@implementation UINavigationItem (FixSpace)

-(void)setLeftCustomViewBarButtonItemAndFixSpace:(UIBarButtonItem*)barButtonItem {
    if(system_version >= 7.0){
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -16;
        self.leftBarButtonItems = @[negativeSpacer, barButtonItem];
    }else {
        self.leftBarButtonItem = barButtonItem;
    }
}

-(void)setRightCustomViewBarButtonItemAndFixSpace:(UIBarButtonItem*)barButtonItem {
    if(system_version >= 7.0){
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -16;
        self.rightBarButtonItems = @[negativeSpacer, barButtonItem];
    }else {
        self.rightBarButtonItem = barButtonItem;
    }
}

-(void)setBackBarButtonItemWithTitle:(NSString*)title  target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"leftBack"] forState:UIControlStateNormal];
    
    if (title) {
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        [button setTitle:title forState:UIControlStateNormal];
        CGSize fontSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:button.titleLabel.font} context:nil].size;
        button.frame = CGRectMake(0, 0, fontSize.width + 30, 44);
    }else {
        button.frame = CGRectMake(0, 0, 20, 44);
    }
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self setLeftCustomViewBarButtonItemAndFixSpace:barButtonItem];
}

@end

@implementation NSString(EncodingDecoding)

+(NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding{
    return [[NSString alloc] initWithData:data encoding:encoding];
}

+(NSString*)stringWithUTF8EncodingData:(NSData*)data{
    return [NSString stringWithData:data encoding:NSUTF8StringEncoding];
}

-(NSString *)URLEncodedString{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
    return result;
}

-(NSString*)URLDecodedString{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));
    return result;
}

+(NSString*)MD5String:(NSString*)str{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}

+(NSInteger)lengthOfString:(NSString*)str {
    NSRange range = NSMakeRange(0x4e00, 0x9fa5 - 0x4e00);
    NSCharacterSet *nameCharactersCn = [[NSCharacterSet characterSetWithRange:range] invertedSet];
    NSInteger count = 0;
    for (int i = 0; i < str.length; i ++) {
        unichar ch = [str characterAtIndex:i];
        NSRange rangeCn = [[NSString stringWithCharacters:&ch length:1] rangeOfCharacterFromSet:nameCharactersCn];
        if (rangeCn.location == NSNotFound) {
            count = count + 2;
        }else{
            count++;
        }
    }
    return count;
}

@end

@implementation NSString (DecimalNumber)

+(NSString *)floatAccurateToTwoDecimalPlaces:(float)value {
    return [NSString floatAccurateToTwoDecimalPlaces:value ignoreZero:YES];
}

+(NSString *)floatAccurateToTwoDecimalPlaces:(float)value ignoreZero:(BOOL)ignoreZero {
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:value];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    if (ignoreZero) {
        return [roundedOunces stringValue];
    }else {
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setMinimumFractionDigits:2];
        [numberFormatter setMaximumFractionDigits:2];
        [numberFormatter setMinimumIntegerDigits:1];
        NSString *result  = [numberFormatter stringFromNumber:roundedOunces];
        return result;
    }
}

+(NSString *)stringAccurateToTwoDecimalPlaces:(NSString*)value {
    return [NSString stringAccurateToTwoDecimalPlaces:value ignoreZero:YES];
}

+(NSString *)stringAccurateToTwoDecimalPlaces:(NSString*)value ignoreZero:(BOOL)ignoreZero {
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [NSDecimalNumber decimalNumberWithString:value];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    if (ignoreZero) {
        return [roundedOunces stringValue];
    }else {
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setMinimumIntegerDigits:1];
        [numberFormatter setMinimumFractionDigits:2];
        [numberFormatter setMaximumFractionDigits:2];
        NSString *result  = [numberFormatter stringFromNumber:roundedOunces];
        return result;
    }
}

+(NSString*)decimalNumberAddWithOne:(NSString*)oneValue Two:(NSString*)twoValue {//+
    NSDecimalNumber *oneNumber = [NSDecimalNumber decimalNumberWithString:oneValue];
    NSDecimalNumber *twoNumber = [NSDecimalNumber decimalNumberWithString:twoValue];
    NSDecimalNumber *product = [oneNumber decimalNumberByAdding:twoNumber];
    
    return [NSString stringAccurateToTwoDecimalPlaces:[product stringValue]];
}

+(NSString*)decimalNumberSubtractWithOne:(NSString*)oneValue Two:(NSString*)twoValue {//-
    NSDecimalNumber *oneNumber = [NSDecimalNumber decimalNumberWithString:oneValue];
    NSDecimalNumber *twoNumber = [NSDecimalNumber decimalNumberWithString:twoValue];
    NSDecimalNumber *product = [oneNumber decimalNumberBySubtracting:twoNumber];
    return [NSString stringAccurateToTwoDecimalPlaces:[product stringValue]];
}

+(NSString*)decimalNumberDivideWithOne:(NSString*)oneValue Two:(NSString*)twoValue {///
    NSDecimalNumber *oneNumber = [NSDecimalNumber decimalNumberWithString:oneValue];
    NSDecimalNumber *twoNumber = [NSDecimalNumber decimalNumberWithString:twoValue];
    NSDecimalNumber *product = [oneNumber decimalNumberByDividingBy:twoNumber];
    return [NSString stringAccurateToTwoDecimalPlaces:[product stringValue]];
}

+(NSString*)decimalNumberMutiplyWithOne:(NSString*)oneValue Two:(NSString*)twoValue {//*
    NSDecimalNumber *oneNumber = [NSDecimalNumber decimalNumberWithString:oneValue];
    NSDecimalNumber *twoNumber = [NSDecimalNumber decimalNumberWithString:twoValue];
    NSDecimalNumber *product;
    if ([[NSDecimalNumber notANumber] isEqualToNumber:oneNumber]) {
        product = [NSDecimalNumber zero];
    }else {
        product = [oneNumber decimalNumberByMultiplyingBy:twoNumber];
    }
    return [NSString stringAccurateToTwoDecimalPlaces:[product stringValue]];
}

+(NSComparisonResult)decimalNumberCompareWithOne:(NSString*)oneValue Two:(NSString*)twoValue {
    NSDecimalNumber *oneNumber = [NSDecimalNumber decimalNumberWithString:oneValue];
    NSDecimalNumber *twoNumber = [NSDecimalNumber decimalNumberWithString:twoValue];
    NSComparisonResult result = [oneNumber compare:twoNumber];
    //    if (result ==NSOrderedAscending) {
    //        (@"oneValue < twoValue小于");
    //    } else if (result == NSOrderedSame) {
    //        (@"oneValue == twoValue等于");
    //    } else if (result ==NSOrderedDescending) {
    //        (@"oneValue > twoValue大于");
    //    }
    return result;
}

@end

@implementation NSString (BankId)

-(NSString *)normalNumToBankNum
{
    NSString *tmpStr = [self bankNumToNormalNum];
    
    NSInteger size = (tmpStr.length / 4);
    
    NSMutableArray *tmpStrArr = [[NSMutableArray alloc] init];
    for (int n = 0;n < size; n++)
    {
        [tmpStrArr addObject:[tmpStr substringWithRange:NSMakeRange(n*4, 4)]];
    }
    
    [tmpStrArr addObject:[tmpStr substringWithRange:NSMakeRange(size*4, (tmpStr.length % 4))]];
    
    tmpStr = [tmpStrArr componentsJoinedByString:@" "];
    
    return tmpStr;
}

-(NSString *)bankNumToNormalNum
{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end

@implementation NSString (LabelLines)

- (NSArray *)getSeparatedLinesWithWidth:(CGFloat)width font:(UIFont*)font {
    
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,width,MAXFLOAT));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [self substringWithRange:range];
        [linesArray addObject:lineString];
    }
    
    CFRelease(frame);
    CGPathRelease(path);
    CFRelease(frameSetter);
    CFRelease(myFont);
    
    return (NSArray *)linesArray;
}

@end

@implementation UILabel (LineNumber)

-(NSInteger)textLineNumber {
    CGSize fontSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
    NSInteger count = (fontSize.height) / self.font.lineHeight;
    return count;
}

@end

@implementation NSDictionary (ResponseAnalyze)

-(id)filterNull:(id)object {
    if (equal_json_null(object)) {
        return nil;
    }else {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (NSString *key in [object allKeys]) {
                id item = [object objectForKey:key];
                id value = [self filterNull:item];
                if (value) {
                    [dict setObject:value forKey:key];
                }
            }
            return dict;
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (id item in object) {
                id newItem = [self filterNull:item];
                if (newItem) {
                    [array addObject:newItem];
                }
            }
            return array;
        }
        else {
            return object;
        }
    }
    
    return nil;
}

-(id)analyzeJson {
    id result = nil;
    if (self) {
        if ([@"ok" isEqualToString:[self objectForKey:@"status"]]) {
            id data = [self objectForKey:@"data"];
            if (data) {
                result = [self filterNull:data];
            }
        }
    }
    return result;
}

@end

#pragma mark - UIImage(Color)

@implementation UIImage (Color)
+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)partImageInRect:(CGRect)rect {
    CGImageRef imageRef=CGImageCreateWithImageInRect([self CGImage],rect);
    UIImage *image=[UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

-(void)saveToDocumentWithName:(NSString*)imageName {
    NSData* imageData = UIImageJPEGRepresentation(self,1.0);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = @"";
    if (paths.count > 0) {
        documentsDirectory = [paths objectAtIndex:0];
    }
    // Now we get the full path to the file
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
}

- (UIImage*)scaledToSize:(CGSize)newSize {
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

+(UIImage *)compressImageWith:(UIImage *)image
{
    if (image.size.width > 0 && image.size.height > 0) {
        float imageScaleX = MIN([[UIScreen mainScreen] bounds].size.width/image.size.width, 1.0);
        float imageScaleY = MIN([[UIScreen mainScreen] bounds].size.height/image.size.height, 1.0);
        float imageScale = MIN(imageScaleX, imageScaleY);
        float imageWidth = imageScale * image.size.width * [UIScreen mainScreen].scale;
        float imageHeight = imageScale * image.size.height * [UIScreen mainScreen].scale;
        
        if (imageWidth > 0 && imageHeight > 0) {
            UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageHeight));
            [image drawInRect:CGRectMake(0, 0, imageWidth , imageHeight)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            image = nil;
            return newImage;
        }
    }
    
    image = nil;
    return [UIImage imageNamed:@"serviceItemDefult.png"];
}

@end

#pragma mark - UIView (Border)

@implementation UIView (Border)

-(void)setViewBorderWidth:(float)width Color:(UIColor *)color Radius:(float)radius {
    [self setViewBorderWidth:width Color:color];
    [self setViewRadius:radius];
}

-(void)setViewRadius:(float)radius {
    [self.layer setCornerRadius:radius];//圆角
    [self.layer setMasksToBounds:YES];
}

-(void)setViewBorderWidth:(float)width Color:(UIColor *)color {
    [self.layer setBorderWidth:width];//画线的宽度
    [self.layer setBorderColor:color.CGColor];//颜色
}

-(void)removeAllSubViews {
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
}

-(void)removeSubViewWithTag:(NSInteger)tag {
    for (UIView *item in [self subviews]) {
        if (item.tag == tag) {
            [item removeFromSuperview];
        }
    }
}

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, self.bounds.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, self.bounds.size.height - borderWidth, self.bounds.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, self.bounds.size.height);
    [self.layer addSublayer:border];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(self.bounds.size.width - borderWidth, 0, borderWidth, self.bounds.size.height);
    [self.layer addSublayer:border];
}

- (void)addBorderWithColor:(UIColor *)color andFrame:(CGRect) frame {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = frame;
    [self.layer addSublayer:border];
}

-(void)addShadow {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,1);
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 1;
}

@end

@implementation UIView (findFirstResponder)

-(UIView*)findFirstResponderBeneathView {
    // Search recursively for first responder
    for ( UIView *childView in self.subviews){
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder]) return childView;
        UIView *result = [childView findFirstResponderBeneathView];
        if (result)return result;
    }
    return nil;
}

-(void)disableScrollsToTopPropertyOnAllSubviews {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).scrollsToTop = NO;
        }
        [subview disableScrollsToTopPropertyOnAllSubviews];
    }
}

@end

@implementation UITableView (HideCellLine)

- (void)setExtraCellLineHidden{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:view];
    [self setTableHeaderView:view];
}

@end

@implementation UITextField (keyBoardCustomView)
-(void)setupKeyBoardCustomView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40)];
    bgView.backgroundColor = UIColorFromRGB(0x000000, 0.5);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 50, 0, 50, 40);
    [bgView addSubview:button];
    @weakify_self
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        @strongify_self
        [self resignFirstResponder];
    }];
    
    [self setInputAccessoryView:bgView];
}

@end

@implementation UITextView (keyBoardCustomView)
-(void)setupKeyBoardCustomView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40)];
    bgView.backgroundColor = UIColorFromRGB(0x000000, 0.5);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 50, 0, 50, 40);
    [bgView addSubview:button];
    @weakify_self
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        @strongify_self
        [self resignFirstResponder];
    }];
    
    [self setInputAccessoryView:bgView];
}

@end

#pragma mark - UIAlertView (Block)

@implementation UIAlertView (Block)

-(void) handlerClickedButton:(UIAlertViewClickBlock)aBlock {
    self.delegate = self;
    objc_setAssociatedObject(self, @"daoway.UIAlertView.clicked", aBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UIAlertViewClickBlock block = objc_getAssociatedObject(self, @"daoway.UIAlertView.clicked");
    
    if (block) {
        block(alertView, buttonIndex);
    }
}

@end


@implementation UIButton(Block)

- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    objc_setAssociatedObject(self, @"daoway.UIButton.clicked", block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}

- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, @"daoway.UIButton.clicked");
    if (block) {
        block();
    }
}

@end