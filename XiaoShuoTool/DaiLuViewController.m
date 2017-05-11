//
//  DaiLuViewController.m
//  XiaoShuoTool
//
//  Created by 安风 on 2017/5/11.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "DaiLuViewController.h"
#import "Masonry.h"

@interface DaiLuViewController ()

@property(nonatomic,strong) UIButton *wechatBtu;
@property(nonatomic,strong) UITextField *textField;
@property(nonatomic,strong) UIButton *tijiaoBtu;

@end

@implementation DaiLuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"带路党";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#efeff5"];
    
    UMBannerView *bannerView = [UMVideoAd videoBannerPlayerFrame:CGRectMake(0, 64, self.view.frame.size.width, 50) videoBannerPlayCloseCallBackBlock:^(BOOL isLegal){
        NSLog(@"关闭banner");
        NSLog(@"close banner");
    }];
    
    [self.view addSubview:bannerView];
    
    _wechatBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    _wechatBtu.backgroundColor = [UIColor whiteColor];
    [_wechatBtu addTarget:self action:@selector(copyWechat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_wechatBtu];
    
    [_wechatBtu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(64+65);
        make.height.mas_equalTo(44);
    }];
    
    
    UILabel *label = [[UILabel alloc]init];
    label.text = [AppUnitl sharedManager].model.wetchat.url;
    label.textColor = [UIColor colorWithHexString:@"#FF6A6A"];
    [_wechatBtu addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       make.edges.equalTo(_wechatBtu).insets(UIEdgeInsetsMake(0, 13, 0, 13));
    }];
    
    
    UIView *textView = [[UIView alloc]init];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(_wechatBtu.mas_bottom).offset(15);
        make.height.mas_equalTo(44);
    }];
    
    _textField = [[UITextField alloc]init];
    _textField.placeholder = @"老司机VIP码";
    [textView addSubview:_textField];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(textView).insets(UIEdgeInsetsMake(0, 13, 0, 13));
    }];
    
    _tijiaoBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    _tijiaoBtu.backgroundColor = [UIColor whiteColor];
    [_tijiaoBtu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_tijiaoBtu setTitle:@"提交" forState:UIControlStateNormal];
    [_tijiaoBtu addTarget:self action:@selector(tijiaolaosiji) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_tijiaoBtu];
    
    [_tijiaoBtu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(textView).offset(65);
        make.height.mas_equalTo(44);
    }];
}

-(void)tijiaolaosiji{

}

-(void)copyWechat{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [AppUnitl sharedManager].model.wetchat.url;

    UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"提示"message:@"已复制老司机微信号，是否前往寻找老司机？" delegate:self   cancelButtonTitle:@"待会儿" otherButtonTitles:@"前往",nil];
    [infoAlert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *str = @"weixin:/";
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
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
