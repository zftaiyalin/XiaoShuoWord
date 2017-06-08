//
//  UploadViewController.m
//  XiaoShuoTool
//
//  Created by 曾富田 on 2017/5/17.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "UploadViewController.h"
@import GoogleMobileAds;
#import "NSObject+ALiHUD.h"

@interface UploadViewController ()<GADRewardBasedVideoAdDelegate>{
    BOOL isRequestVideo;
}


@end

@implementation UploadViewController

- (instancetype) init{
    self = [super init];
    if (self){
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(void)huoqujifen{
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
    }else{
        [self requestRewardedVideo];
        isRequestVideo = YES;
        [self showText:@"正在获取广告"];
    }
    
}


- (void)requestRewardedVideo {
    GADRequest *request = [GADRequest request];
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:@"ca-app-pub-3676267735536366/6453222138"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"视频上传";
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"支持作者" style:UIBarButtonItemStylePlain target:self action:@selector(huoqujifen)];
    
    self.navigationItem.rightBarButtonItem = item;
    
    
    UIImageView *wifiImage = [[UIImageView alloc]init];
    wifiImage.image = [UIImage imageNamed:@"wifisj.png"];
    wifiImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:wifiImage];
    
    [wifiImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64+64);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerX.equalTo(self.view);
    }];
    
    
    UIImageView *pcImage = [[UIImageView alloc]init];
    pcImage.image = [UIImage imageNamed:@"pc.png"];
    [self.view addSubview:pcImage];
    
    [pcImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wifiImage.mas_left).offset(-26);
        make.size.mas_equalTo(CGSizeMake(62, 62));
        make.centerY.equalTo(wifiImage);
    }];
    
    
    UIImageView *sjImage = [[UIImageView alloc]init];
    sjImage.image = [UIImage imageNamed:@"shouji.png"];
    [self.view addSubview:sjImage];
    
    [sjImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wifiImage.mas_right).offset(13);
        make.size.mas_equalTo(CGSizeMake(62, 62));
        make.centerY.equalTo(wifiImage);
    }];
    
    
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor colorWithHexString:@"#dbdbdb"];
    backView.layer.cornerRadius = 10;
    [self.view addSubview:backView];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(pcImage.mas_bottom).offset(44);
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(200);
    }];
    
    
    
    
    UILabel *wifiLabel = [[UILabel alloc]init];
    wifiLabel.backgroundColor = [UIColor colorWithHexString:@"#515151"];
    wifiLabel.textAlignment = NSTextAlignmentCenter;
    wifiLabel.layer.cornerRadius = 5;
    wifiLabel.font = [UIFont systemFontOfSize:15];
    wifiLabel.textColor = [UIColor colorWithHexString:@"#f4ea2a"];
    wifiLabel.clipsToBounds = YES;
    wifiLabel.text = self.ipString;
    [backView addSubview:wifiLabel];
    
    [wifiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(20);
        make.right.equalTo(backView).offset(-20);
        make.height.mas_equalTo(30);
        make.center.equalTo(backView);
    }];
    
    UILabel *webLabel = [[UILabel alloc]init];
    webLabel.textAlignment = NSTextAlignmentCenter;
    webLabel.font = [UIFont systemFontOfSize:20];
    webLabel.textColor = [UIColor whiteColor];
    webLabel.text = @"WEB服务已启动";
    [backView addSubview:webLabel];
    
    [webLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(20);
        make.right.equalTo(backView).offset(-20);
        make.height.mas_equalTo(30);
        make.centerX.equalTo(backView);
        make.bottom.equalTo(wifiLabel.mas_top).offset(-10);
    }];
    
    UILabel *tishiLabel = [[UILabel alloc]init];
    tishiLabel.textAlignment = NSTextAlignmentCenter;
    tishiLabel.font = [UIFont systemFontOfSize:11];
    tishiLabel.textColor = [UIColor whiteColor];
    tishiLabel.text = @"请在同一WiFi的情况下，在电脑端浏览器输入以上IP";
    [backView addSubview:tishiLabel];
    
    [tishiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(20);
        make.right.equalTo(backView).offset(-20);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(backView);
        make.top.equalTo(wifiLabel.mas_bottom).offset(10);
    }];

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
    NSString *string = [[NSString alloc]initWithFormat:@"谢谢观看,当前积分%d",[[AppUnitl sharedManager] getMyintegral]];
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
