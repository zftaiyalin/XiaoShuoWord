//
//  YouJiVideoModel.m
//  XiaoShuoTool
//
//  Created by 安风 on 2017/5/8.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "YouJiVideoModel.h"

@implementation YouJiVideoModel


- (NSMutableArray *)videoModel {
    if (!_videoModel) {
        _videoModel = [[NSMutableArray alloc]init];
    }
    return _videoModel;
}
@end
