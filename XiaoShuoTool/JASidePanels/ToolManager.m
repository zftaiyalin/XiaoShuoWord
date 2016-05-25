//
//  ToolManager.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "ToolManager.h"

@implementation ToolManager

static ToolManager *instance;
+ (instancetype)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+(ToolManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
        [instance getXiaoShuo];
         [instance getGeci];
         [instance getShici];
    });
    return instance;
}

-(void)getXiaoShuo{
    NSData *udObject =[[NSUserDefaults standardUserDefaults]objectForKey:@"anfeng_xiaoshuo"];
    self.xiaoshuo = [NSKeyedUnarchiver unarchiveObjectWithData:udObject] ;

    if (self.xiaoshuo==nil) {
       self.xiaoshuo =[[MainModel alloc]init];
    }
}


-(void)saveXiaoShuo{
    
    NSData *udObject = [NSKeyedArchiver archivedDataWithRootObject:_xiaoshuo];

    [[NSUserDefaults standardUserDefaults]setObject:udObject forKey:@"anfeng_xiaoshuo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setXiaoshuo:(MainModel *)xiaoshuo{
    _xiaoshuo=xiaoshuo;
    [self saveXiaoShuo];
}

-(void)getShici{
    NSData *udObject =[[NSUserDefaults standardUserDefaults]objectForKey:@"anfeng_shici"];
    self.shici = [NSKeyedUnarchiver unarchiveObjectWithData:udObject] ;
    if (self.shici==nil) {
        self.shici=[[MainModel alloc]init];
    }
}

-(void)saveShiCi{
     NSData *udObject = [NSKeyedArchiver archivedDataWithRootObject:_shici];
    [[NSUserDefaults standardUserDefaults]setObject:udObject forKey:@"anfeng_shici"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setShici:(MainModel *)shici{
    _shici=shici;
    [self saveShiCi];
}



-(void)getGeci{
    NSData *udObject =[[NSUserDefaults standardUserDefaults]objectForKey:@"anfeng_geci"];
    self.geci = [NSKeyedUnarchiver unarchiveObjectWithData:udObject] ;
    if (self.geci==nil) {
        self.geci=[[MainModel alloc]init];
    }
}


-(void)saveGeci{
    NSData *udObject = [NSKeyedArchiver archivedDataWithRootObject:_geci];
    [[NSUserDefaults standardUserDefaults]setObject:udObject forKey:@"anfeng_geci"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setGeci:(MainModel *)geci{
    _geci=geci;
    [self saveGeci];
}

@end
