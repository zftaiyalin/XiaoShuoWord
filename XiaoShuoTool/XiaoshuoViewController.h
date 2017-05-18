//
//  XiaoshuoViewController.h
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "JADebugViewController.h"
#import "VideoPlayModel.h"
#import "AdvertisingViewController.h"

@interface XiaoshuoViewController : JADebugViewController

@property(nonatomic, strong) NSMutableArray *videoModelArray;
@property (nonatomic, assign) int pageIndex;
@property(nonatomic,strong)VideoPlayModel *model;

@end
