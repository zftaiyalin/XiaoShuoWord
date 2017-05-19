//
//  DaiLuViewController.m
//  XiaoShuoTool
//
//  Created by 安风 on 2017/5/11.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "DaiLuViewController.h"
#import "AES128Util.h"
#import "NSObject+ALiHUD.h"

@interface DaiLuViewController ()

@property(nonatomic,strong) UIButton *wechatBtu;
@property(nonatomic,strong) UITextField *textField;
@property(nonatomic,strong) UIButton *tijiaoBtu;
@property(nonatomic,strong) UILabel *jgLabel;
@end

@implementation DaiLuViewController

-(void)huoqujifen{
    [UMVideoAd videoPlay:self videoPlayFinishCallBackBlock:^(BOOL isFinishPlay){
        if (isFinishPlay) {
            NSLog(@"视频播放结束");
            
        }else{
            NSLog(@"中途退出");
            [MobClick event:@"中途关闭广告"];
        }
        
    } videoPlayConfigCallBackBlock:^(BOOL isLegal){
        NSString *message = @"";
        if (isLegal) {
            message = @"此次播放有效";
            [MobClick event:@"有效播放广告"];
            [[AppUnitl sharedManager] addMyintegral:[AppUnitl sharedManager].model.video.ggintegral];
            NSString *string = [[NSString alloc]initWithFormat:@"获取%d积分,当前积分%d",[AppUnitl sharedManager].model.video.ggintegral,[[AppUnitl sharedManager] getMyintegral]];
            [self showSuccessText:string];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissLoading];
            });
            
        }else{
            
            message = @"此次播放无效";
            [self showErrorText:message];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissLoading];
            });
        }
        //                UIImage *image = [MobiVideoAd oWVideoImage];
        NSLog(@"是否有效：%@",message);
    }];
    
}
-(void)dealloc{
    NSLog(@"释放控制器");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"带路党";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#efeff5"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"获取积分" style:UIBarButtonItemStylePlain target:self action:@selector(huoqujifen)];
    
    self.navigationItem.rightBarButtonItem = item;
    
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
    
    
    _jgLabel = [[UILabel alloc]init];
    _jgLabel.text = [NSString stringWithFormat:@"我的积分：%d",[[AppUnitl sharedManager]getMyintegral]];
    _jgLabel.numberOfLines = 0;
    _jgLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    _jgLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_jgLabel];
    
    [_jgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(13);
        make.right.equalTo(self.view).offset(-13);
        make.top.equalTo(_wechatBtu.mas_bottom).offset(15);
    }];

    
    
    UIView *textView = [[UIView alloc]init];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(_jgLabel.mas_bottom).offset(15);
        make.height.mas_equalTo(44);
    }];
    
    _textField = [[UITextField alloc]init];
    _textField.placeholder = @"免广告积分码";
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
    if ([self IsChinese:_textField.text]) {
        
        [self showErrorText:@"错误的验证码"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissLoading];
        });
        return;
    }
    
    
    NSString *decryStr = [AES128Util AES128Decrypt:_textField.text key:[AppUnitl sharedManager].model.video.key];
    NSLog(@"decryStr: %@", decryStr);
    
    if ([decryStr rangeOfString:@"jifen"].length > 0) {
        
        
        NSArray *dateArray = [decryStr componentsSeparatedByString:@"jifen"];
        
        
        BOOL flag = [AppUnitl addCodeToJifen:dateArray];
        
        if (flag) {
            [self showSuccessText:@"获取积分码成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissLoading];
                _jgLabel.text = [NSString stringWithFormat:@"我的积分：%d",[[AppUnitl sharedManager]getMyintegral]];
            });
        }else{
            [self showErrorText:@"积分码已使用"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissLoading];
            });
        }

        
    }else{
        
        [self showErrorText:@"错误的验证码"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissLoading];
        });
    }
    
}

-(BOOL)IsChinese:(NSString *)str
{
    for(int i=0; i< [str length];i++)
    {
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)//判断输入的是否是中文
        {
            return YES;
        }
    }
    return NO;
}


-(void)copyWechat{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [AppUnitl sharedManager].model.wetchat.url;

    UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"提示"message:@"已复制老司机微信号，是否前往寻找老司机？" delegate:self   cancelButtonTitle:@"待会儿" otherButtonTitles:@"前往",nil];
    [infoAlert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [MobClick event:@"前往微信"];
        
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
