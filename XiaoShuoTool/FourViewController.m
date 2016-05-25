//
//  FourViewController.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "FourViewController.h"
#import "YYTextView.h"
#import "MMAlertView.h"
#import "ToolManager.h"
#import "UIColor+YYAdd.h"
#import "NSAttributedString+YYText.h"

@interface FourViewController ()<YYTextViewDelegate>{
    UILabel *_textView;
    NSMutableArray *wordArray;
    
}

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    wordArray=[NSMutableArray array];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    item.title = @"";
    self.navigationItem.backBarButtonItem = item;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(edit)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    _textView=[[UILabel alloc]initWithFrame:self.view.bounds];
    _textView.backgroundColor=[UIColor colorWithRed:((float)((0xf1eef5 & 0xFF0000) >> 16))/255.0
                                                                       green:((float)((0xf1eef5 & 0xFF00) >> 8))/255.0
                                                                        blue:((float)(0xf1eef5 & 0xFF))/255.0
                                              alpha:1.0];
    _textView.font=[UIFont systemFontOfSize:20];
    _textView.numberOfLines=0;
//    _textView.placeholderText=@"文章";
//    _textView.placeholderFont=[UIFont systemFontOfSize:20];
    if (_mainData.content.length>0) {
        [self textAttritbute];
    }
//    _textView.delegate=self;
    [self.view addSubview:_textView];
    
    
}
-(void)edit{
    
    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
        NSLog(@"animation complete");
    };
    
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithInputTitle:@"添加类型标签" detail:nil placeholder:@"类型标签" handler:^(NSString *text) {
        NSLog(@"input:%@",text);
        
        if(text.length>0){
            [self addStatusTagsInfo:text];
        }
    }];
    alertView.maxInputLength=10;
    alertView.attachedView = self.view;
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleExtraLight;
    [alertView showWithBlock:completeBlock];
}

-(void)addStatusTagsInfo:(NSString *)text{
    [_mainData.wordArray addObject:text];
    [self textAttritbute];
    [[ToolManager sharedInstance]saveXiaoShuo];
}

-(void)textAttritbute{
    NSMutableAttributedString *feekong=[[NSMutableAttributedString alloc]initWithString:_mainData.content];


    [feekong addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, _mainData.content.length)];

    [_mainData.wordArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str=(NSString *)obj;

        NSRange range=[_mainData.content rangeOfString:str];

        if (range.length>0) {

            NSString* encodedText = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://dict.baidu.com/s?wd=%@",encodedText]];


            [feekong appendAttributedString:[NSAttributedString hyperlinkFromString:str withURL:url]];


            

        }
    }];


    _textView.attributedText=feekong;

}

-(void)viewWillDisappear:(BOOL)animated{
    
   [[ToolManager sharedInstance]saveXiaoShuo];
    
}

-(void)textViewDidChange:(YYTextView *)textView{
    if (textView.text.length>0) {
        _mainData.content=textView.text;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
