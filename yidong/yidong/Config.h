//
//  Config.h
//  daowei
//
//  Created by Aily on 14-9-24.
//
//

#ifndef daowei_Config_h
#define daowei_Config_h

/**
 *  强弱引用转换，用于解决代码块（block）与强引用self之间的循环引用问题
 *  调用方式: `@weakify_self`实现弱引用转换，`@strongify_self`实现强引用转换
 *
 *  @weakify_self
 *  [obj block:^{
 *  @strongify_self
 *      self.property = something;
 *  }];
 */
#ifndef	weakify_self
#if __has_feature(objc_arc)
#define weakify_self autoreleasepool{} __weak __typeof__(self) weakSelf = self;
#else
#define weakify_self autoreleasepool{} __block __typeof__(self) blockSelf = self;
#endif
#endif
#ifndef	strongify_self
#if __has_feature(objc_arc)
#define strongify_self try{} @finally{} __typeof__(weakSelf) self = weakSelf;
#else
#define strongify_self try{} @finally{} __typeof__(blockSelf) self = blockSelf;
#endif
#endif

#define system_version                  [[[UIDevice currentDevice] systemVersion] floatValue]
#define is_ipad                         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?YES:NO)
#define isRetina                        ([[UIScreen mainScreen] scale]==1?NO:YES)
#define is_iphone_3_5inch               ([UIScreen mainScreen].bounds.size.height == 480.0)
#define is_iphone_4inch                 ([UIScreen mainScreen].bounds.size.height == 568.0)
#define is_iphone_4_7inch               ([UIScreen mainScreen].bounds.size.height == 667.0)
#define is_iphone_5_5inch               ([UIScreen mainScreen].bounds.size.height == 736.0)
#define filePathMainBundle(file)        [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@",file]
#define filePathDocument(file)          [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",file]
#define UIColorFromRGB(rgbValue,a)      [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define equal_json_null(value)          (!value || [[NSString stringWithFormat:@"%@",value] isEqualToString:@"(null)"] || [[NSString stringWithFormat:@"%@",value] isEqualToString:@"<null>"] || [[NSString stringWithFormat:@"%@",value] isEqualToString:@"null"])

#define RootVC                          [[[UIApplication sharedApplication] keyWindow] rootViewController]

#endif
