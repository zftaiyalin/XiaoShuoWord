//
//  NewDateCodeViewController.m
//  XiaoShuoTool
//
//  Created by 曾富田 on 2017/5/12.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "NewDateCodeViewController.h"
#import "Masonry.h"
#import "AES128Util.h"

@interface NewDateCodeViewController (){
    UITextField *textfield;
    UIButton *_tijiaoBtu;

}

@end

@implementation NewDateCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    textfield = [[UITextField alloc]init];
    textfield.placeholder = @"输入天数";
    textfield.backgroundColor = [UIColor colorWithHexString:@"#efeff5"];
    [self.view addSubview:textfield];
    
    [textfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(79);
        make.height.mas_equalTo(44);
    }];
    
    _tijiaoBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    _tijiaoBtu.backgroundColor = [UIColor whiteColor];
    [_tijiaoBtu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_tijiaoBtu setTitle:@"提交" forState:UIControlStateNormal];
    [_tijiaoBtu addTarget:self action:@selector(tijiaolaosiji) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_tijiaoBtu];
    
    [_tijiaoBtu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(textfield).offset(59);
        make.height.mas_equalTo(44);
    }];
    
    
    
}

-(void)tijiaolaosiji{
    
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeInterval  interval =24*60*60*textfield.text.intValue; //1:天数
    NSDate*date1 = [[AppUnitl.sharedManager getInternetDate] initWithTimeIntervalSinceNow:+interval];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate*dateNow = [NSDate date];
    
//    NSLog(@"%@", [AppUnitl.sharedManager getStringToDate:[AppUnitl.sharedManager getInternetDate]]);
    NSString *jiami = [[NSString alloc]initWithFormat:@"%@create%@",[dateFormatter stringFromDate:dateNow],[dateFormatter stringFromDate:date1]];
    
    NSString *key = [AppUnitl sharedManager].model.video.key;
    NSString *encryStr = [AES128Util AES128Encrypt:jiami key:key];
    NSLog(@"encryStr: %@", encryStr);
    
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = encryStr;
    
  
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
