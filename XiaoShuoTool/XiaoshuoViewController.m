//
//  XiaoshuoViewController.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

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


//#define baseUrl "https://www.youjizz.com/most-popular/"

static NSString * const reuseIdentifier = @"collectionViewCell";

@interface XiaoshuoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ZFPlayerDelegate>{
    
    
}

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZFPlayerView        *playerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic,strong) NSMutableArray *indexArray;

@end

@implementation XiaoshuoViewController


-(void)loadVideoModel {
    _pageIndex = (arc4random() % _model.vdieoMaxIndex)+1;
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@%d.html",_baseUrl,_pageIndex];
    
    [self OCGumboVideoModel:urlString];
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
            
            if (htmlString) {
                OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
                NSArray *rows = iosfeedDoc.body.Query(@"div.main-content").find(@"div.video-item");
                YouJiVideoModel *array = [[YouJiVideoModel alloc]init];
                 [self.videoModelArray removeAllObjects];
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
                    
                    
                    if (array.videoModel.count < 10) {
                        [array.videoModel addObject:model];
                    }else{
                        [self.videoModelArray addObject:array];
                        array = [[YouJiVideoModel alloc]init];
                    }
                }
                
                if (array.videoModel.count != 10) {
                    [self.videoModelArray addObject:array];
                }
            }
            _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadVideoModel)];
            [_collectionView.mj_footer endRefreshing];
            [_collectionView.mj_header endRefreshing];
            [_collectionView reloadData];
        });

    });
            
            
        
        
   
}

-(void)reFreshVideoModel {
    _pageIndex = (arc4random() % _model.vdieoMaxIndex)+1;
   
    NSString *urlString = [[NSString alloc]initWithFormat:@"%@%d.html",_baseUrl,_pageIndex];
    [self OCGumboVideoModel:urlString];
}

-(void)setModel:(VideoPlayModel *)model{
    _model = model;
    self.baseUrl =  [AES128Util AES128Decrypt:_model.videoUrl key:[AppUnitl sharedManager].model.video.key];
}
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.videoModelArray = [[NSMutableArray alloc]init];
    self.indexArray = [[NSMutableArray alloc]init];
    self.pageIndex = (arc4random() % _model.vdieoMaxIndex)+1;
//    self.title = @"首页";
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"获取积分" style:UIBarButtonItemStylePlain target:self action:@selector(huoqujifen)];
    
    self.navigationItem.rightBarButtonItem = item;
    self.view.backgroundColor = [UIColor whiteColor];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 5;
    CGFloat itemWidth = ScreenWidth/2 - 2*margin;
    CGFloat itemHeight = itemWidth*9/16 + 30;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.sectionInset = UIEdgeInsetsMake(10, margin, 10, margin);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;

    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 375, 667) collectionViewLayout:layout];
    _collectionView.backgroundColor=[UIColor whiteColor];
   
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reFreshVideoModel)];
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadVideoModel)];

    [_collectionView registerClass:[ZFCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    [self.view addSubview:_collectionView];

    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self reFreshVideoModel];
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    YouJiVideoModel *model = [self.videoModelArray objectAtIndex:section];
    
    return model.videoModel.count;
}

//一共有多少个组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.videoModelArray.count;
}

//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margin = 5;
    CGFloat itemWidth = ScreenWidth/2 - 2*margin;
    CGFloat itemHeight = itemWidth*9/16 + 30;
    return CGSizeMake(itemWidth, itemHeight);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // 取到对应cell的model
    
    YouJiVideoModel *array = [self.videoModelArray objectAtIndex:indexPath.section];
    
    __block VideoModel *vmodel        = array.videoModel[indexPath.row];
    // 赋值model
    cell.model                         = vmodel;
    __block NSIndexPath *weakIndexPath = indexPath;
    __block ZFCollectionViewCell *weakCell = cell;
    __weak typeof(self)  weakSelf      = self;
    // 点击播放的回调
    cell.playBlock = ^(UIButton *btn){

        
        if ([[AppUnitl sharedManager] getWatchQuanxian]) {
            
            NSString *string = [[NSString alloc]initWithFormat:@"使用%d积分,剩余%d积分!",[AppUnitl sharedManager].model.video.wkintegral,[[AppUnitl sharedManager] getMyintegral]];
            [weakSelf showSuccessText:string];
       
           
        
            
            dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
            
            // 2.调用异步函数
            dispatch_async(queue, ^{
//                [weakSelf.playerView shutDownPlayer];
                
                NSString *base = [AES128Util AES128Decrypt:[AppUnitl sharedManager].model.video.baseUrl key:[AppUnitl sharedManager].model.video.key];
                NSString *urlString = [[NSString alloc]initWithFormat:@"%@%@",base,vmodel.url];
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
                        [weakSelf showErrorText:@"错误的视频链接,已返还积分!"];
                        [[AppUnitl sharedManager] addMyintegral:[AppUnitl sharedManager].model.video.wkintegral];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf dismissLoading];
                        });
                        return;
                    }
                    [weakSelf dismissLoading];
                    ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
                    playerModel.title            = vmodel.title;
                    playerModel.videoModel = vmodel;
                    playerModel.videoURL         = [[NSURL alloc]initWithString:video];
                    NSString *image = [[NSString alloc]initWithFormat:@"https:%@",vmodel.img];
                    playerModel.placeholderImageURLString = image;
                    playerModel.scrollView       = weakSelf.collectionView;
                    playerModel.indexPath        = weakIndexPath;
                    // 赋值分辨率字典
                    //        playerModel.resolutionDic    = dic;
                    // player的父视图tag
                    playerModel.fatherViewTag    = weakCell.topicImageView.tag;
                    
                    // 设置播放控制层和model
                    [weakSelf.playerView playerControlView:nil playerModel:playerModel];
                    // 下载功能
                    weakSelf.playerView.hasDownload = YES;
                    // 自动播放
                    [weakSelf.playerView autoPlayTheVideo];
                    [MobClick event:@"播放视频"];
                });
                
            });
        }else{
            
            NSString *string = [[NSString alloc]initWithFormat:@"当前%d积分不足,观看所需积分%d!",[[AppUnitl sharedManager] getMyintegral],[AppUnitl sharedManager].model.video.wkintegral];
            [weakSelf showErrorText:string];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismissLoading];
            });
        }
        
    };
    
    return cell;
}



- (ZFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [ZFPlayerView sharedPlayerView];
        _playerView.delegate = self;
        // 当cell播放视频由全屏变为小屏时候，不回到中间位置
        _playerView.cellPlayerOnCenter = NO;
        
        // 当cell划出屏幕的时候停止播放
        // _playerView.stopPlayWhileCellNotVisable = YES;
        //（可选设置）可以设置视频的填充模式，默认为（等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
        // 静音
        // _playerView.mute = YES;
    }
    return _playerView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ZFPlayerControlView alloc] init];
    }
    return _controlView;
}

#pragma mark - ZFPlayerDelegate

- (void)zf_playerDownload:(NSString *)url {
    // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
    NSString *name = [url lastPathComponent];
    [[ZFDownloadManager sharedDownloadManager] downFileUrl:url filename:name fileimage:nil];
    // 设置最多同时下载个数（默认是3）
    [ZFDownloadManager sharedDownloadManager].maxCount = 4;
}


@end
