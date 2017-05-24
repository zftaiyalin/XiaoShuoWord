//
//  XiaoshuoViewController.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//
@import GoogleMobileAds;
#import "XiaoshuoViewController.h"
#import "MMAlertView.h"
#import "OCGumbo.h"
#import "OCGumbo+Query.h"
#import "VideoModel.h"
#import "MJRefresh.h"
#import "ZFPlayer.h"
#import "ZFCollectionViewCell.h"
#import "ZFDownloadManager.h"
#import "UMVideoAd.h"
#import "YouJiVideoModel.h"
#import "NSObject+ALiHUD.h"
#import "AES128Util.h"
#import "WifiVideoTableViewCell.h"
#import "MoviePlayerViewController.h"


//#define baseUrl "https://www.youjizz.com/most-popular/"

static NSString * const reuseIdentifier = @"collectionViewCell";

@interface XiaoshuoViewController ()<ZFPlayerDelegate,GADRewardBasedVideoAdDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    BOOL isRefresh;
    int index;
}

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZFPlayerView        *playerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) NSString *baseUrl;

@end

@implementation XiaoshuoViewController


-(void)loadVideoModel {
    _pageIndex = (arc4random() % _model.vdieoMaxIndex)+1;
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@%d.html",_baseUrl,_pageIndex];
    isRefresh =NO;
    if ([self reloadVideoArray]) {
        [self OCGumboVideoModel:urlString];
    }
    
}

-(void)dealloc{
    NSLog(@"释放控制器");
}

-(void)OCGumboVideoModel:(NSString *)urlString  {
   
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 2.调用异步函数
    dispatch_async(queue, ^{
        
        // 1.下载图片
        NSError *error = nil;
        //    https://www.youjizz.com/most-popular/2.html
        NSURL *xcfURL = [NSURL URLWithString:urlString];
        NSString *htmlString = [NSString stringWithContentsOfURL:xcfURL encoding:NSUTF8StringEncoding error:&error];
        
        // 3.回到主线程更新UI
        //        self.imageView.image = image;
        /*
         技巧:
         如果想等UI更新完毕再执行后面的代码, 那么使用同步函数
         如果不想等UI更新完毕就需要执行后面的代码, 那么使用异步函数
         */
        dispatch_sync(dispatch_get_main_queue(), ^{ // 会等block代码执行完毕后，执行后面最后一句的打印代码
            NSLog(@"%@", htmlString);
            
            //    OCGumboElement *element = document.Query(@"body").find(@".video-item").find(@".video-title").first();
            if (![[GADRewardBasedVideoAd sharedInstance] isReady]) {
                [self requestRewardedVideo];
            }
            if (htmlString) {
                OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
                NSArray *rows = iosfeedDoc.body.Query(@"div.main-content").find(@"div.video-item");
                YouJiVideoModel *array = [[YouJiVideoModel alloc]init];
                
                if (isRefresh) {
                    index = 0;
                    [self.videoModelArray removeAllObjects];
                }
                
                for (OCGumboNode *row in rows) {
                    OCGumboNode *title = row.Query(@".video-title").first();
                    NSLog(@"title:[%@]", title.text());
                    OCGumboNode *link = row.Query(@".frame").first();
                    NSLog(@"from:(%@)",link.attr(@"href"));
                    OCGumboNode *time = row.Query(@".time").first();
                    NSLog(@"title:[%@]", time.text());
                    OCGumboNode *img = row.Query(@".img-responsive").first();
                    NSLog(@"title:[%@]", img.attr(@"data-original"));
                    //            NSLog(@"by %@ \n", row.Query(@"p.meta").children(@"a").get(1).text());
                    
                    VideoModel *model = [[VideoModel alloc]init];
                    model.url = link.attr(@"href");
                    model.title = title.text();
                    model.time = time.text();
                    model.img = img.attr(@"data-original");
                    
                    [array.videoModel addObject:model];
                    if (array.videoModel.count == 5) {
                 
                        [self.videoModelArray addObject:array];
                        array = [[YouJiVideoModel alloc]init];
                    }
                }
                
                if (array.videoModel.count != 5) {
                    [self.videoModelArray addObject:array];
                }
            }
            
    
            [self reloadVideoArray];
            
            
        });

    });

}

-(BOOL)reloadVideoArray{
    
    if (self.videoModelArray.count > index) {
        [self.tableModelArray addObject:[self.videoModelArray objectAtIndex:index]];
        [_tableView reloadData];
        [_tableView.mj_footer endRefreshing];
        [_tableView.mj_header endRefreshing];
        index ++;
        return NO;
    }else{
        return YES;
    }
}

-(void)reFreshVideoModel {
    _pageIndex = (arc4random() % _model.vdieoMaxIndex)+1;
   
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@%d.html",_baseUrl,_pageIndex];
  
    isRefresh = YES;
    [self OCGumboVideoModel:urlString];
    
    
    
}

-(void)setModel:(VideoPlayModel *)model{
    _model = model;
    self.baseUrl =  [AES128Util AES128Decrypt:_model.videoUrl key:[AppUnitl sharedManager].model.video.key];
}
-(void)huoqujifen{
    
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
    }else{
    
    [UMVideoAd videoPlay:self videoPlayFinishCallBackBlock:^(BOOL isFinishPlay){
        if (isFinishPlay) {
            NSLog(@"视频播放结束");
            
        }else{
            NSLog(@"中途退出");
            [MobClick event:@"中途关闭有米视频"];
        }

    } videoPlayConfigCallBackBlock:^(BOOL isLegal){
        NSString *message = @"";
        if (isLegal) {
            message = @"此次播放有效";
            [MobClick event:@"有效播放有米视频广告"];
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

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    self.videoModelArray = [[NSMutableArray alloc]init];
    self.tableModelArray = [[NSMutableArray alloc]init];
    self.pageIndex = (arc4random() % _model.vdieoMaxIndex)+1;
//    self.title = @"首页";
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"获取积分" style:UIBarButtonItemStylePlain target:self action:@selector(huoqujifen)];
    
    self.navigationItem.rightBarButtonItem = item;
    self.view.backgroundColor = [UIColor whiteColor];

    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[WifiVideoTableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reFreshVideoModel)];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadVideoModel)];
    
    GADBannerView *ban = [[GADBannerView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, 50)];
    ban.adUnitID = @"ca-app-pub-3676267735536366/4976488930";
    ban.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    request.testDevices = @[
                            @"fe9239b402756b9539e3beb3a686378d"  // Eric's iPod Touch
                            ];
    [ban loadRequest:request];
    
    [self.view addSubview:ban];

    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(ban.mas_bottom);
        make.bottom.equalTo(self.view);
    }];

    
    
    [self reFreshVideoModel];
    
    if (![[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [self requestRewardedVideo];
    }
}

- (void)requestRewardedVideo {
    GADRequest *request = [GADRequest request];
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:@"ca-app-pub-3676267735536366/6453222138"];
}


// 页面消失时候
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playerView resetPlayer];
    self.playerView.delegate = nil;
    self.playerView = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [self requestRewardedVideo];
    }
    [MobClick beginLogPageView:@"进入老司机页面"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 这里设置横竖屏不同颜色的statusbar
    if (ZFPlayerShared.isLandscape) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return ZFPlayerShared.isStatusBarHidden;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Table view data source



- (BOOL)shouldAutorotate
{
    return NO;
}







- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableModelArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    YouJiVideoModel *array = [self.videoModelArray objectAtIndex:section];

    return array.videoModel.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WifiVideoTableViewCell *cell =(WifiVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    YouJiVideoModel *array = [self.videoModelArray objectAtIndex:indexPath.section];
    
    VideoModel *vmodel        = array.videoModel[indexPath.row];
    
    [cell loadVideoData:vmodel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if ([[AppUnitl sharedManager] getWatchQuanxian]) {
        
        NSString *string = [[NSString alloc]initWithFormat:@"使用%d积分,剩余%d积分!",[AppUnitl sharedManager].model.video.wkintegral,[[AppUnitl sharedManager] getMyintegral]];
        [self showSuccessText:string];
        
        
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        YouJiVideoModel *array = [self.videoModelArray objectAtIndex:indexPath.section];
        
        VideoModel *model        = array.videoModel[indexPath.row];

        // 2.调用异步函数
        dispatch_async(queue, ^{
            //                [weakSelf.playerView shutDownPlayer];
            
            NSString *base = [AES128Util AES128Decrypt:[AppUnitl sharedManager].model.video.baseUrl key:[AppUnitl sharedManager].model.video.key];
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




#pragma mark GADRewardBasedVideoAdDelegate implementation

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
