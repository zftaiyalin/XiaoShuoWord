//
//  MainModel.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "MainModel.h"

@implementation MainModel
@synthesize array=_array, string=_string,diFlag=_diFlag;

-(instancetype)init{
    self=[super init];
    if (self) {
        self.array=[NSMutableArray array];
        self.diFlag=@0;
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.array = [coder decodeObjectForKey:@"array"];
        self.string = [coder decodeObjectForKey:@"name"];
        self.diFlag=[coder decodeObjectForKey:@"diFlag"];
        self.wordData=[coder decodeObjectForKey:@"wordData"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:_array forKey:@"array"];
    [coder encodeObject:_string forKey:@"name"];
     [coder encodeObject:_diFlag forKey:@"diFlag"];
    [coder encodeObject:_wordData forKey:@"wordData"];
}

@end
