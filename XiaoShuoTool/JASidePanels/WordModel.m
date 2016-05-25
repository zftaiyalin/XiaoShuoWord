//
//  WordModel.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "WordModel.h"

@implementation WordModel

//@property(nonatomic,strong)NSAttributedString *arr;
//@property(nonatomic,strong)NSString *content;
//@property(nonatomic,strong)NSMutableArray *wordArray;
@synthesize wordArray=_wordArray;

-(instancetype)init{
    self=[super init];
    if (self) {
        self.wordArray=[NSMutableArray array];
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init]){
        self.wordArray = [coder decodeObjectForKey:@"wordArray"];
        self.title = [coder decodeObjectForKey:@"title"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
     [coder encodeObject:_wordArray forKey:@"wordArray"];
     [coder encodeObject:_title forKey:@"title"];
    
}

@end
