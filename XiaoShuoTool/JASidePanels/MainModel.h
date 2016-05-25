//
//  MainModel.h
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordModel.h"

@interface MainModel : NSObject

@property(nonatomic,strong)NSMutableArray *array;
@property(nonatomic,strong)NSString *string;
@property(nonatomic,strong)NSNumber *diFlag;
@property(nonatomic,strong)WordModel *wordData;
@end
