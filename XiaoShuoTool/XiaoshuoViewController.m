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
#import "YouJiVideoModel.h"
#import "NSObject+ALiHUD.h"
#import "AES128Util.h"
#import "WifiVideoTableViewCell.h"
#import "MoviePlayerViewController.h"
#import "FanYiSDK.h"
#import <MediaPlayer/MediaPlayer.h>


static NSString * const reuseIdentifier = @"collectionViewCell";

@interface XiaoshuoViewController ()<ZFPlayerDelegate,GADRewardBasedVideoAdDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    UITableView *_tableView;
    BOOL isRefresh;
    BOOL isSearch;
    int index;
    int pageMaxIndex;
    BOOL isRequestVideo;
    UISearchBar* _searchBar;
    YDTranslateRequest *translateRequest;
}

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZFPlayerView        *playerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) MPMoviePlayerViewController *playerVc;

@end

@implementation XiaoshuoViewController

-(int)getRandomNumber:(int)from to:(int)to

{
    
    return (int)(from + (arc4random() % (to-from+1)));
    
}


-(void)loadVideoModel {
 
    isRefresh =NO;
    if ([self reloadVideoArray]) {
        if (pageMaxIndex != 0 && !isSearch) {
            _pageIndex = [self getRandomNumber:1 to:pageMaxIndex];
        }else{
            _pageIndex += 1;
        }
        
        NSString *urlString = nil;
        if ([self.model.videoTitle isEqualToString:@"站1"]) {
            urlString = [[NSString alloc]initWithFormat:@"%@%d",_baseUrl,_pageIndex];
        }else{
            urlString = [[NSString alloc]initWithFormat:@"%@%d.html",_baseUrl,_pageIndex];
        }
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

            if (htmlString) {
                
                
                if (isRefresh) {
                    index = 0;
                    [self.videoModelArray removeAllObjects];
                    [self.tableModelArray removeAllObjects];
                }
                
                
                NSMutableArray *muArray = [NSMutableArray array];
                NSMutableArray *urlArray = [NSMutableArray array];
                
                if ([self.model.videoTitle isEqualToString:@"站1"]) {
                    
                    OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
                    
                    NSArray *rows = iosfeedDoc.Query(@"li.videoBox");
                    
                    for (OCGumboNode *row in rows) {
                        
                        OCGumboNode *link = row.Query(@"div.videoPreviewBg").find(@"img").first();
                        if (link == nil) {
                            continue;
                        }
                        VideoModel *model = [[VideoModel alloc]init];

                 
                        if (link.attr(@"data-mediumthumb").length > 0) {
                            NSLog(@"title:[%@]", link.attr(@"data-mediumthumb"));
                            model.img = link.attr(@"data-mediumthumb");
                        }else if (link.attr(@"data-image").length > 0){
                            NSLog(@"title:[%@]", link.attr(@"data-image"));
                            model.img = link.attr(@"data-image");
                        }
                        OCGumboNode *slink = row.Query(@"div.phimage").find(@"a").first();
                        NSLog(@"link:[%@]", slink.attr(@"href"));
                        NSLog(@"title:[%@]", slink.attr(@"title"));
                        
                       
                        model.url = slink.attr(@"href");
                        model.title = slink.attr(@"title");
                        model.time = @"";
                        
                        model.baseUrl = self.model.baseurl;
                        
                        [muArray addObject:model];
                        [urlArray addObject:model.url];
                    }

                    
                }else{
                

                    OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
                    NSArray *rows = iosfeedDoc.body.Query(@"div.main-content").find(@"div.video-item");
                    
                    OCGumboNode *page = iosfeedDoc.body.Query(@"ul.mobilePager").find(@"li.label").first();
                    if (page != nil) {
                        NSArray *pagearray = [page.text() componentsSeparatedByString:@"of "];
                        NSString *pageStr = pagearray.lastObject;
                        pageMaxIndex = [pageStr intValue];
                    }else{
                        pageMaxIndex = 0;
                        _pageIndex = 1;
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
                        model.baseUrl = self.model.baseurl;
                        
                        [muArray addObject:model];
                        [urlArray addObject:model.url];
                    }
                    
                }
                
                
                
                
                YouJiVideoModel *array = [[YouJiVideoModel alloc]init];
                NSArray *mm = [self chanceChongfu:muArray andUrl:urlArray];
                int j = 0;
                for (VideoModel * model in mm) {
                    [array.videoModel addObject:model];
                    if (array.videoModel.count == 8) {
                        
                        [self.videoModelArray addObject:array];
                        if (j != mm.count - 1) {
                            array = [[YouJiVideoModel alloc]init];
                        }
                        
                    }
                    
                    j++;
                }
                
                if (array.videoModel.count != 8) {
                    [self.videoModelArray addObject:array];
                }
                
            }
            
    
            [self reloadVideoArray];
            
            
        });

    });

}

-(NSMutableArray *)chanceChongfu:(NSMutableArray *)array andUrl:(NSMutableArray *)urlArray{


    
    NSMutableArray *muarray = [NSMutableArray array];
    NSSet *set = [NSSet setWithArray:urlArray];
    NSLog(@"%@",[set allObjects]);
    
    for (NSString *string in [set allObjects]) {
        for (VideoModel * model in array) {
            if ([model.url isEqualToString:string]) {
                [muarray addObject:model];
                break;
            }
        }
    }
    
    return muarray;
    
}

-(BOOL)reloadVideoArray{
    
    if (self.videoModelArray.count > index) {
        if ([[AppUnitl sharedManager] getWatchQuanxian:AppUnitl.sharedManager.model.video.refreshintegral]) {
            [self.tableModelArray addObject:[self.videoModelArray objectAtIndex:index]];
            
            [_tableView.mj_footer endRefreshing];
            [_tableView.mj_header endRefreshing];
            index ++;
            
            self.title = [NSString stringWithFormat:@"积分%d",[AppUnitl sharedManager].getMyintegral];
            [_tableView reloadData];
            [self dismissLoading];
            return NO;
        }else{
            NSString *string = [[NSString alloc]initWithFormat:@"当前积分不足,获取资源需要%d积分",[AppUnitl sharedManager].model.video.refreshintegral];
            [self showErrorText:string];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissLoading];
            });
            [_tableView.mj_footer endRefreshing];
            [_tableView.mj_header endRefreshing];
            
         return NO;
        }
    }else{
        return YES;
    }
}

-(void)reFreshVideoModel {
    
    if (pageMaxIndex != 0 && !isSearch) {
        _pageIndex = [self getRandomNumber:1 to:pageMaxIndex];
    }else{
        _pageIndex = 1;
    }
    NSString *urlString = nil;
    if ([self.model.videoTitle isEqualToString:@"站1"]) {
        urlString = [[NSString alloc]initWithFormat:@"%@%d",_baseUrl,_pageIndex];
    }else{
        urlString = [[NSString alloc]initWithFormat:@"%@%d.html",_baseUrl,_pageIndex];
    }
    isRefresh = YES;
    [self OCGumboVideoModel:urlString];
    
    
    
}

-(void)setModel:(VideoPlayModel *)model{
    _model = model;
    self.baseUrl =  [AES128Util AES128Decrypt:_model.topUrl key:[AppUnitl sharedManager].model.video.key];
}
-(void)huoqujifen{
    [MobClick event:@"播放激励广告"];
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
    }else{
        [self requestRewardedVideo];
        isRequestVideo = YES;
        [self showText:@"正在获取积分广告"];
    }
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    translateRequest  = [YDTranslateRequest request];
    
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 30, 30)];
    
    // 设置没有输入时的提示占位符
    [_searchBar setPlaceholder:@"人物名/作品名/番号"];
    // 显示Cancel按钮
    _searchBar.showsCancelButton = true;
    // 设置代理
    _searchBar.delegate = self;
    
    [_searchBar setShowsCancelButton:NO];// 是否显示取消按钮
    
   
    
    
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    self.videoModelArray = [[NSMutableArray alloc]init];
    self.tableModelArray = [[NSMutableArray alloc]init];
    self.pageIndex = 1;

    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"获取积分" style:UIBarButtonItemStylePlain target:self action:@selector(huoqujifen)];
    self.title = [NSString stringWithFormat:@"积分%d",[AppUnitl sharedManager].getMyintegral];
    self.navigationItem.rightBarButtonItem = item;
    self.view.backgroundColor = [UIColor whiteColor];

    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[WifiVideoTableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reFreshVideoModel)];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadVideoModel)];
    
    GADBannerView *ban = [[GADBannerView alloc]initWithFrame:CGRectMake(0, 64+50, self.view.width, 50)];
    ban.adUnitID = @"ca-app-pub-3676267735536366/4976488930";
    ban.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    
    [ban loadRequest:request];
    
    [self.view addSubview:ban];
    
     [self.view addSubview:_searchBar];
    
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.height.mas_equalTo(50);
    }];

    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(ban.mas_bottom);
        make.bottom.equalTo(self.view);
    }];

    
    
    [self reFreshVideoModel];
    
//    if (![[GADRewardBasedVideoAd sharedInstance] isReady]) {
//        [self requestRewardedVideo];
//    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self posttranslates];
}

-(void)posttranslates{
    
    [self showText:@"正在搜索"];
    [MobClick event:@"搜索视频"];
    YDTranslateParameters *parameters =
    [YDTranslateParameters targeting];
    parameters.appKey = @"4fef944745713f93";
    parameters.source = @"宅男影音先锋";
    parameters.from = @"中文";
    parameters.to = @"英文";
    parameters.offLine = YES;
    translateRequest.translateParameters = parameters;
    if (_searchBar.text.stringByTrim.length == 0) {
        return;
    }
    [translateRequest lookup:_searchBar.text WithCompletionHandler:^(YDTranslateRequest *request, YDTranslate *translte, NSError *error) {
        if (error) {
            NSString *des = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            NSLog(@"================> %ld%@", (long)error.code,des);
            [self showErrorText:[NSString stringWithFormat:@"搜索失败:%@", des]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissLoading];
            });
        } else {
            NSString *fanyi = translte.translation[0];
            isSearch = YES;
            self.baseUrl = [NSString stringWithFormat:@"%@%@%@",[AES128Util AES128Decrypt:_model.searchUrlWord key:[AppUnitl sharedManager].model.video.key],fanyi,[AES128Util AES128Decrypt:_model.searchUrlPage key:[AppUnitl sharedManager].model.video.key]];
            pageMaxIndex = 0;
            [self reFreshVideoModel];
            
            if(fanyi == nil){
                
                [self showErrorText:[NSString stringWithFormat:@"抱歉，遇到错误，请重新输入"]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissLoading];
                });
                
                return;
            }

        }
    }];
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
//    if (![[GADRewardBasedVideoAd sharedInstance] isReady]) {
//        [self requestRewardedVideo];
//    }
    self.title = [NSString stringWithFormat:@"积分%d",[AppUnitl sharedManager].getMyintegral];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [MobClick endLogPageView:@"退出老司机页面"];
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
    
    YouJiVideoModel *array = [self.tableModelArray objectAtIndex:section];

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
    
    YouJiVideoModel *array = [self.tableModelArray objectAtIndex:indexPath.section];
    
    VideoModel *vmodel        = array.videoModel[indexPath.row];
    
    [cell loadVideoData:vmodel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if ([[AppUnitl sharedManager] getWatchQuanxian:AppUnitl.sharedManager.model.video.wkintegral]) {
        
        NSString *string = [[NSString alloc]initWithFormat:@"使用%d积分,剩余%d积分!",[AppUnitl sharedManager].model.video.wkintegral,[[AppUnitl sharedManager] getMyintegral]];
        [self showText:string];
        
        
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        YouJiVideoModel *array = [self.tableModelArray objectAtIndex:indexPath.section];
        
        VideoModel *model        = array.videoModel[indexPath.row];

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
                
                if ([self.model.videoTitle isEqualToString:@"站1"]) {
                    
//                    AppUnitl.sharedManager.isDownLoad = NO;
                    OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

                    NSArray *arr = iosfeedDoc.Query(@"script");

                    for (OCGumboNode *row in arr) {

                        if ([row.attr(@"type") isEqualToString:@"text/javascript"] ) {

                            NSString *text = row.text();
                           
                            if ([text rangeOfString:@"videoUrl"].length > 0) {
                                
                                NSArray *arrs = [text componentsSeparatedByString:@"\"videoUrl\":\""];
                                
                                for (NSString *vi in arrs) {
                                    if ([vi rangeOfString:@".mp4?"].length > 0) {
                                        NSArray *arrd = [vi componentsSeparatedByString:@"\"}"];
                                        NSLog(@"from:(%@)",arrd.firstObject);
                                        NSLog(@"from:()");
                                        video = arrd.firstObject;
                                    }
                                }
                            }
                        }
                    }
                    

                    
                }else{
//                    AppUnitl.sharedManager.isDownLoad = YES;
                    OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
                    NSArray *array = iosfeedDoc.body.Query(@"div.main-content").find(@"#yj-video");
                    
                    
                    for (OCGumboNode *row in array) {
                        OCGumboNode *videoStr = row.Query(@"source").last();
                        NSLog(@"from:(%@)",videoStr.attr(@"src"));
                        video = [[NSString alloc]initWithFormat:@"https:%@",videoStr.attr(@"src")];
                    }

                }
                
            }
            dispatch_sync(dispatch_get_main_queue(), ^{ // 会等block代码执行完毕后，执行后面最后一句的打印代码
                if (video == nil) {
                    [self dismissLoading];
                    [self showErrorText:@"错误的视频链接,已返还积分!"];
                    [[AppUnitl sharedManager] addMyintegral:[AppUnitl sharedManager].model.video.wkintegral];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self dismissLoading];
                    });
                    return;
                }else{
                    [self dismissLoading];
                    MoviePlayerViewController *movie = [[MoviePlayerViewController alloc]init];
                    if ([self.model.videoTitle isEqualToString:@"站1"]) {
                    
                        video = [video stringByReplacingOccurrencesOfString:@"\\" withString:@"`"];
                        movie.isDown = NO;
                        movie.isShowCollect = NO;
                    }else{
                        movie.isDown = YES;
                        movie.isShowCollect = YES;
                    }
                    
                    movie.videoURL                   = [[NSURL alloc]initWithString:video];
                    movie.titleSring = model.title;
                    movie.videoModel = model;
                    [self.navigationController pushViewController:movie animated:NO];
               
                    [MobClick event:@"播放视频"];
                    
                }
            });
            
        });
    }else{
        
        NSString *string = [[NSString alloc]initWithFormat:@"当前%d积分不足,观看所需积分%d!",[[AppUnitl sharedManager] getMyintegral],[AppUnitl sharedManager].model.video.wkintegral];
        [self showErrorText:string];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissLoading];
        });
    }
    
    self.title = [NSString stringWithFormat:@"积分%d",[AppUnitl sharedManager].getMyintegral];
    [_tableView reloadData];
    
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
