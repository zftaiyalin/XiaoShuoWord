//
//  AppUnitl.m
//  XiaoShuoTool
//
//  Created by 曾富田 on 2017/5/11.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "AppUnitl.h"

@implementation AppUnitl
+ (AppUnitl *)sharedManager
{
    static AppUnitl *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}


/**
 
 *  获取网络当前时间
 
 */

- (NSDate *)getInternetDate

{
    
    NSString *urlString = @"http://m.baidu.com";
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    // 实例化NSMutableURLRequest，并进行参数配置
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString: urlString]];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    [request setTimeoutInterval: 2];
    
    [request setHTTPShouldHandleCookies:FALSE];
    
    [request setHTTPMethod:@"GET"];
    
    
    
    NSHTTPURLResponse *response;
    
    [NSURLConnection sendSynchronousRequest:request
     
                          returningResponse:&response error:nil];
    
    
    
    // 处理返回的数据
    
    //    NSString *strReturn = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    
    
    NSLog(@"response is %@",response);
    
    NSString *date = [[response allHeaderFields] objectForKey:@"Date"];
    
    date = [date substringFromIndex:5];
    
    date = [date substringToIndex:[date length]-4];
    
    
    
    
    
    NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
    
    
    
    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    
    
    
    NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
    
    return netDate;
    
}

@end
