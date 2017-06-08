//
//  CollectionViewController.m
//  XiaoShuoTool
//
//  Created by 曾富田 on 2017/5/18.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "CollectionViewController.h"
#import "WifiVideoTableViewCell.h"
#import "MoviePlayerViewController.h"
#import "VideoModel.h"
#import "NSObject+ALiHUD.h"
#import "OCGumbo.h"
#import "OCGumbo+Query.h"
#import "AES128Util.h"
@import GoogleMobileAds;

@interface CollectionViewController ()<UITableViewDelegate,UITableViewDataSource,GADRewardBasedVideoAdDelegate>{
    UITableView *_tableView;
    UILabel *label;
    NSMutableArray *videoArray;
    BOOL isRequestVideo;
}

@end

@implementation CollectionViewController
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    self.title = @"收藏";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"获取积分" style:UIBarButtonItemStylePlain target:self action:@selector(huoqujifen)];
    
    self.navigationItem.rightBarButtonItem = item;
    
    
//    GADBannerView *ban = [[GADBannerView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, 50)];
//    ban.adUnitID = @"ca-app-pub-3676267735536366/5566428138";
//    ban.rootViewController = self;
//    
//    GADRequest *request = [GADRequest request];
//
//    [ban loadRequest:request];
//    
//    [self.view addSubview:ban];
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.hidden = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[WifiVideoTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    
    label = [[UILabel alloc]init];
    label.textColor = [UIColor colorWithHexString:@"#bfbfbf"];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.text = @"没有收藏的视频呢";
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
  
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self getVideoArrayToPhone];
    
}


-(void)getVideoArrayToPhone{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"mycollection"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    videoArray = [NSMutableArray arrayWithArray:array];
    
    if (videoArray.count > 0) {
        _tableView.hidden = NO;
        label.hidden = YES;
        [_tableView reloadData];
    }else{
        _tableView.hidden = YES;
        label.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"释放控制器");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return videoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WifiVideoTableViewCell *cell =(WifiVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    VideoModel *model = [videoArray objectAtIndex:indexPath.row];
    [cell loadVideoData:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if ([[AppUnitl sharedManager] getWatchQuanxian:AppUnitl.sharedManager.model.video.wkintegral]) {
        
        NSString *string = [[NSString alloc]initWithFormat:@"使用%d积分,剩余%d积分!",[AppUnitl sharedManager].model.video.wkintegral,[[AppUnitl sharedManager] getMyintegral]];
        [self showSuccessText:string];
        
      
  
        
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
         VideoModel *model = [videoArray objectAtIndex:indexPath.row];
        // 2.调用异步函数
        dispatch_async(queue, ^{
            //                [weakSelf.playerView shutDownPlayer];
            
            NSString *base = [AES128Util AES128Decrypt:model.baseUrl key:[AppUnitl sharedManager].model.video.key];
            NSString *urlString = [[NSString alloc]initWithFormat:@"%@%@",base,model.url];
            NSError *error = nil;
            NSURL *xcfURL = [NSURL URLWithString:urlString];
            NSString *htmlString = [NSString stringWithContentsOfURL:xcfURL encoding:NSUTF8StringEncoding error:&error];
            __block NSString *video = nil;
            
            
            if (htmlString) {
                OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
                NSArray *array = iosfeedDoc.body.Query(@"div.main-content").find(@"#yj-video");
                
                
                for (OCGumboNode *row in array) {
                    OCGumboNode *videoStr = row.Query(@"source").last();
                    NSLog(@"from:(%@)",videoStr.attr(@"src"));
                    video = [[NSString alloc]initWithFormat:@"https:%@",videoStr.attr(@"src")];
                }
                
            }
            dispatch_sync(dispatch_get_main_queue(), ^{ // 会等block代码执行完毕后，执行后面最后一句的打印代码
                if (video == nil) {
                    [self showErrorText:@"错误的视频链接,已返还积分!"];
                    [[AppUnitl sharedManager] addMyintegral:[AppUnitl sharedManager].model.video.wkintegral];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self dismissLoading];
                    });
                    return;
                }
                
                [self dismissLoading];
                MoviePlayerViewController *movie = [[MoviePlayerViewController alloc]init];
                movie.videoURL                   = [[NSURL alloc]initWithString:video];
                movie.titleSring = model.title;
                movie.videoModel = model;
                [self.navigationController pushViewController:movie animated:NO];
                
                [MobClick event:@"播放视频"];
            });
            
        });
    }else{
        
        NSString *string = [[NSString alloc]initWithFormat:@"当前%d积分不足,观看所需积分%d!",[[AppUnitl sharedManager] getMyintegral],[AppUnitl sharedManager].model.video.wkintegral];
        [self showErrorText:string];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissLoading];
        });
    }
    
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [videoArray removeObjectAtIndex:indexPath.row];
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:videoArray];
    [[NSUserDefaults standardUserDefaults]setObject:tempArchive forKey:@"mycollection"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self getVideoArrayToPhone];
    
}

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
    if (isRequestVideo) {
        isRequestVideo = NO;
        [self dismissLoading];
        
        [self showErrorText:@"获取广告失败"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissLoading];
        });
    }
}


@end
