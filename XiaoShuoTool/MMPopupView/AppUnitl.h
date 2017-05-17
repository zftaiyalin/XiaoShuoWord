//
//  AppUnitl.h
//  XiaoShuoTool
//
//  Created by 曾富田 on 2017/5/11.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppModel.h"
@interface AppUnitl : NSObject

@property(nonatomic,strong) AppModel *model;
@property(nonatomic,assign) _Bool isDownLoad;
+ (AppUnitl *)sharedManager;
- (NSDate *)getInternetDate;
+(UIImage *)getImage:(NSString *)videoURL;
+(float)getTime:(NSString *)videoURL;
-(NSString *)getStringToDate:(NSDate *)date;
-(NSDate *)getDateToString:(NSString *)date;
+(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;
-(NSString *)getStringToDate:(NSDate *)date;
+ (BOOL)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;
@end
