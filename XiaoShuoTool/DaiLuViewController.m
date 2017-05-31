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
@import GoogleMobileAds;

@interface DaiLuViewController ()<GADRewardBasedVideoAdDelegate>{
    BOOL isRequestVideo;
}

@property(nonatomic,strong) UIButton *wechatBtu;
@property(nonatomic,strong) UITextField *textField;
@property(nonatomic,strong) UIButton *tijiaoBtu;
@property(nonatomic,strong) UILabel *jgLabel;
@end

@implementation DaiLuViewController

-(void)huoqujifen{
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
    }else{
        [self requestRewardedVideo];
        isRequestVideo = YES;
        [self showText:@"正在获取积分广告"];
        
    }
}

- (void)requestRewardedVideo {
    GADRequest *request = [GADRequest request];
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:@"ca-app-pub-3676267735536366/6453222138"];
}


-(void)dealloc{
    NSLog(@"释放控制器");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [GADRewardBasedVideoAd sharedInstance].delegate = self;
    
    
    self.title = @"带路党";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#efeff5"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"获取积分" style:UIBarButtonItemStylePlain target:self action:@selector(huoqujifen)];
    
    self.navigationItem.rightBarButtonItem = item;

    GADBannerView *ban = [[GADBannerView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, 50)];
    ban.adUnitID = @"ca-app-pub-3676267735536366/5566428138";
    ban.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
//    request.testDevices = @[
//                            @"fe9239b402756b9539e3beb3a686378d"  // Eric's iPod Touch
//                            ];
    [ban loadRequest:request];
    
    [self.view addSubview:ban];
    
    
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
    if ([AppUnitl sharedManager].model.wetchat.isWetchat) {
        label.text = [AppUnitl sharedManager].model.wetchat.wechatnick;
    }else{
        label.text = @"老司机带路群，加群，你懂得😉";
    }
    
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

    
    
//    UIView *textView = [[UIView alloc]init];
//    textView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:textView];
//    
//    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.right.equalTo(self.view);
//        make.top.equalTo(_jgLabel.mas_bottom).offset(15);
//        make.height.mas_equalTo(44);
//    }];
//    
//    _textField = [[UITextField alloc]init];
//    _textField.placeholder = @"免广告积分码";
//    [textView addSubview:_textField];
//    
//    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(textView).insets(UIEdgeInsetsMake(0, 13, 0, 13));
//    }];
//    
//    _tijiaoBtu = [UIButton buttonWithType:UIButtonTypeCustom];
//    _tijiaoBtu.backgroundColor = [UIColor whiteColor];
//    [_tijiaoBtu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [_tijiaoBtu setTitle:@"提交" forState:UIControlStateNormal];
//    [_tijiaoBtu addTarget:self action:@selector(tijiaolaosiji) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_tijiaoBtu];
//    
//    [_tijiaoBtu mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.right.equalTo(self.view);
//        make.top.equalTo(textView).offset(65);
//        make.height.mas_equalTo(44);
//    }];
    
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
    
    if ([AppUnitl sharedManager].model.wetchat.isWetchat) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [AppUnitl sharedManager].model.wetchat.wechatnick;
        
        UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"提示"message:@"已复制老司机微信号，是否前往寻找老司机？" delegate:self   cancelButtonTitle:@"待会儿" otherButtonTitles:@"前往",nil];
        [infoAlert show];
  
    }else{
    [self joinGroup:[AppUnitl sharedManager].model.wetchat.groupUin key:[AppUnitl sharedManager].model.wetchat.key];
    }
    

}

- (BOOL)joinGroup:(NSString *)groupUin key:(NSString *)key{
    [MobClick event:@"添加qq群"];
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", @"643483053",@"3633e772ddb30b8b125efc2d1368fc8de0aec864e100b7a352b337c547bb7877"];
    NSURL *url = [NSURL URLWithString:urlStr];
//    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return YES;
//    }
//    else return NO;
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

#pragma mark GADRewardBasedVideoAdDelegate implementation

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
    if (isRequestVideo) {
        isRequestVideo = NO;
        [self dismissLoading];
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
    }
    
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
    NSLog(@"admob奖励视频开始播放");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    NSLog(@"中途关闭admob奖励视频");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
    NSLog(@"有效的播放admob奖励视频");
    
    [[AppUnitl sharedManager] addMyintegral:[AppUnitl sharedManager].model.video.ggintegral];
    NSString *string = [[NSString alloc]initWithFormat:@"获取%d积分,当前积分%d",[AppUnitl sharedManager].model.video.ggintegral,[[AppUnitl sharedManager] getMyintegral]];
    [self showSuccessText:string];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissLoading];
    });
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
    NSLog(@"点击admo奖励视频准备离开app");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load.");
    NSLog(@"admob奖励视频加载失败");
}


@end
