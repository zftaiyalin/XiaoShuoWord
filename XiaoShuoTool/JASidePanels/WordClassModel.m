//
//  WordClassModel.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "WordClassModel.h"

@implementation WordClassModel
@synthesize wordArray=_wordArray;

-(instancetype)init{
    self=[super init];
    if (self) {
        self.wordArray=[NSMutableArray array];
        self.content=@"";
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init]){
        self.wordArray = [coder decodeObjectForKey:@"wordArray"];
        self.content = [coder decodeObjectForKey:@"content"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:_wordArray forKey:@"wordArray"];
     [coder encodeObject:_content forKey:@"content"];
    
}

@end
