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
#import "Masonry.h"
#import "ZFPlayer.h"
#import "ZFCollectionViewCell.h"
#import <ZFDownload/ZFDownloadManager.h>

//#define baseUrl "https://www.youjizz.com/most-popular/"

static NSString * const reuseIdentifier = @"collectionViewCell";

@interface XiaoshuoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ZFPlayerDelegate>{
    
}

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZFPlayerView        *playerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;


@end

@implementation XiaoshuoViewController


-(void)loadVideoModel {
    _pageIndex += 1;
    NSString *urlString = [[NSString alloc]initWithFormat:@"%s%d.html",baseUrl,_pageIndex];
    
    [self OCGumboVideoModel:urlString];
}

-(void)OCGumboVideoModel:(NSString *)urlString  {
    NSError *error = nil;
    //    https://www.youjizz.com/most-popular/2.html
    NSURL *xcfURL = [NSURL URLWithString:urlString];
    NSString *htmlString = [NSString stringWithContentsOfURL:xcfURL encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"%@", htmlString);
    
    //    OCGumboElement *element = document.Query(@"body").find(@".video-item").find(@".video-title").first();
    
    if (htmlString) {
        OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
        NSArray *rows = iosfeedDoc.body.Query(@"div.main-content").find(@"div.video-item");
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
            [self.videoModelArray addObject:model];
        }
    }
    [_collectionView.mj_footer endRefreshing];
    [_collectionView.mj_header endRefreshing];
    [_collectionView reloadData];
}

-(void)reFreshVideoModel {
    _pageIndex = 1;
    [self.videoModelArray removeAllObjects];
    NSString *urlString = [[NSString alloc]initWithFormat:@"%s%d.html",baseUrl,_pageIndex];
    [self OCGumboVideoModel:urlString];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.videoModelArray = [[NSMutableArray alloc]init];
    self.pageIndex = 1;
    self.title = @"首页";

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
//    layout.scrollDirection=UICollectionViewScrollDirectionVertical;
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
    return self.videoModelArray.count;
}

//一共有多少个组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
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
    __block VideoModel *model        = self.videoModelArray[indexPath.row];
    // 赋值model
    cell.model                         = model;
    __block NSIndexPath *weakIndexPath = indexPath;
    __block ZFCollectionViewCell *weakCell = cell;
    __weak typeof(self)  weakSelf      = self;
    // 点击播放的回调
    cell.playBlock = ^(UIButton *btn){
        
        // 分辨率字典（key:分辨率名称，value：分辨率url)
//        NSMutableDictionary *dic = @{}.mutableCopy;
//        for (ZFVideoResolution * resolution in model.playInfo) {
//            [dic setValue:resolution.url forKey:resolution.name];
//        }
//        // 取出字典中的第一视频URL
//        NSURL *videoURL = [NSURL URLWithString:dic.allValues.firstObject];
        
        
        NSString *urlString = [[NSString alloc]initWithFormat:@"%s%@",youjizz,model.url];
        NSError *error = nil;
        //    https://www.youjizz.com/most-popular/2.html
        NSURL *xcfURL = [NSURL URLWithString:urlString];
        NSString *htmlString = [NSString stringWithContentsOfURL:xcfURL encoding:NSUTF8StringEncoding error:&error];
        
        if (htmlString) {
            OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
            NSArray *array = iosfeedDoc.body.Query(@"div.main-content").find(@"#yj-video");
            //        NSLog(@"%@", videoStr.attr(@"src"));
            NSString *video = nil;
            for (OCGumboNode *row in array) {
                OCGumboNode *videoStr = row.Query(@"source").last();
                NSLog(@"from:(%@)",videoStr.attr(@"src"));
                video = [[NSString alloc]initWithFormat:@"https:%@",videoStr.attr(@"src")];
            }
            
            if (video == nil) {
                return;
            }
            
            ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
            playerModel.title            = model.title;
            playerModel.videoURL         = [[NSURL alloc]initWithString:video];
            NSString *image = [[NSString alloc]initWithFormat:@"https:%@",model.img];
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
