//
//  ToolManager.h
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainModel.h"

@interface ToolManager : NSObject

@property (nonatomic,strong)MainModel *xiaoshuo;
@property (nonatomic,strong)MainModel *shici;
@property (nonatomic,strong)MainModel *geci;

+(ToolManager *)sharedInstance;

-(void)saveXiaoShuo;
-(void)saveShiCi;
-(void)saveGeci;
@end
