//
//  SearchViewController.m
//  XiaoShuoTool
//
//  Created by 曾富田 on 2017/5/9.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "SearchViewController.h"
#import "MJRefresh.h"
#import "VideoPlayModel.h"
#import "XiaoshuoViewController.h"
@import GoogleMobileAds;
@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>{

    BOOL theBool;
    //IBOutlet means you can place the progressView in Interface Builder and connect it to your code
    UIProgressView* myProgressView;
    NSTimer *myTimer;
    UIButton *leftBtu;
    UIButton *rightBtu;
    UIButton *refreshBtu;
    UISearchBar* _searchBar;
}

@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)UIView *bottomView;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索";
    // Do any additional setup after loading the view.
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 30, 30)];
    
    // 设置没有输入时的提示占位符
    [_searchBar setPlaceholder:@"人物名/作品名/番号"];
    // 显示Cancel按钮
    _searchBar.showsCancelButton = true;
    // 设置代理
    _searchBar.delegate = self;
    
    [_searchBar setShowsCancelButton:NO];// 是否显示取消按钮

    
    self.navigationItem.titleView = _searchBar;
    
    self.view.backgroundColor = [UIColor whiteColor];

    
//    NSData *htmlData = [[NSData alloc] initWithContentsOfURL:xcfURL];
//    
//    NSString *ssss = [[NSString alloc]initWithData:htmlData encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"=========%@", ssss);

    
    _webView = [[UIWebView alloc]init];
    _webView.opaque = NO;
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];


    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.view);
        make.height.equalTo(self.view).offset(-44);
    }];
    
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.hidden = YES;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableview];
    
    
    
    
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(_webView).offset(64);
        make.bottom.equalTo(self.view);
    }];
    
    // 仿微信进度条
    CGFloat progressBarHeight = 2.f;
    
    myProgressView = [[UIProgressView alloc] init];
    myProgressView.trackTintColor = [UIColor whiteColor];
    myProgressView.progressTintColor = [UIColor colorWithRed:43.0/255.0 green:186.0/255.0  blue:0.0/255.0  alpha:1.0];
    [self.view addSubview:myProgressView];
    
    
    [myProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(_webView);
        make.top.equalTo(self.view).offset(64);
        make.height.mas_equalTo(progressBarHeight);
    }];
    
    _bottomView = [[UIView alloc]init];
    _bottomView.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
    [self.view addSubview:_bottomView];
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    leftBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtu setImage:[UIImage imageNamed:@"unleft.png"] forState:UIControlStateNormal];
    [leftBtu addTarget:self action:@selector(gowebBack) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:leftBtu];
    
    [leftBtu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomView);
        make.top.and.bottom.equalTo(_bottomView);
        make.width.mas_equalTo(66);
    }];
    
    
    rightBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtu setImage:[UIImage imageNamed:@"unright.png"] forState:UIControlStateNormal];
    [rightBtu addTarget:self action:@selector(gowebgoForward) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:rightBtu];
    
    [rightBtu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftBtu.mas_right);
        make.top.and.bottom.equalTo(_bottomView);
        make.width.mas_equalTo(66);
    }];
    
    refreshBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtu setImage:[UIImage imageNamed:@"shuaxin.png"] forState:UIControlStateNormal];
    [refreshBtu addTarget:self action:@selector(gorefresh) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:refreshBtu];
    
    [refreshBtu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bottomView);
        make.top.and.bottom.equalTo(_bottomView);
        make.width.mas_equalTo(66);
    }];
    
//    GADBannerView *ban = [[GADBannerView alloc]initWithFrame:CGRectMake(0, 64+50, self.view.width, 50)];
//    ban.adUnitID = @"ca-app-pub-3676267735536366/8482868532";
//    ban.rootViewController = self;
//    
//    GADRequest *request = [GADRequest request];
//    // Requests test ads on devices you specify. Your test device ID is printed to the console when
//    // an ad request is made. GADBannerView automatically returns test ads when running on a
//    // simulator.
////        request.testDevices = @[
////                                @"fe9239b402756b9539e3beb3a686378d"  // Eric's iPod Touch
////                                ];
//    [ban loadRequest:request];
//    
////    [self.view addSubview:ban];
//    
//    [_tableview setTableFooterView:ban];
    
//    NSString *wstring = [NSString stringWithFormat:@"http://games.softgames.de/down-the-hill/?p=honeybeesoft.net"];
//    
//    
//    NSURL* url = [NSURL URLWithString:wstring];//创建URL
//    NSURLRequest* ssrequest = [NSURLRequest requestWithURL:url];//创建NSURLRequest
//    [_webView loadRequest:ssrequest];//加载
    
}

-(void)gowebgoForward{
    
    if (_webView.canGoForward) {
        [rightBtu setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
    }else{
        [rightBtu setImage:[UIImage imageNamed:@"unright.png"] forState:UIControlStateNormal];
    }
    
    [_webView goForward];
}

-(void)gowebBack{
    if (_webView.canGoBack) {
         [leftBtu setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
    }else{
         [leftBtu setImage:[UIImage imageNamed:@"unleft.png"] forState:UIControlStateNormal];
    }

    [_webView goBack];
}


-(void)gorefresh{

    [_webView reload];

}


- (void)webViewDidStartLoad:(UIWebView *)webView{
    myProgressView.hidden = NO;
    myProgressView.progress = 0;
    theBool = false;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    theBool = true;
    if (_webView.canGoForward) {
        [rightBtu setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
    }else{
        [rightBtu setImage:[UIImage imageNamed:@"unright.png"] forState:UIControlStateNormal];
    }

    if (_webView.canGoBack) {
        [leftBtu setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
    }else{
        [leftBtu setImage:[UIImage imageNamed:@"unleft.png"] forState:UIControlStateNormal];
    }
    
}
-(void)timerCallback {
    if (theBool) {
        if (myProgressView.progress >= 1) {
            myProgressView.hidden = true;
            [myTimer invalidate];
        }
        else {
            myProgressView.progress += 0.1;
        }
    }
    else {
        myProgressView.progress += 0.05;
        if (myProgressView.progress >= 0.95) {
            myProgressView.progress = 0.95;
        }
    }
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _tableview.hidden = YES;
    _webView.hidden = NO;
    myProgressView.hidden = NO;
    _bottomView.hidden = NO;

}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if ([searchBar.text rangeOfString:[AppUnitl sharedManager].model.video.url].length > 0 && [AppUnitl sharedManager].model.wetchat.isShow) {
        _tableview.hidden = NO;
        _webView.hidden = YES;
        myProgressView.hidden = YES;
        _bottomView.hidden = YES;
    }else{
        _tableview.hidden = YES;
        _webView.hidden = NO;
        myProgressView.hidden = NO;
        _bottomView.hidden = NO;
        NSString *wstring;
        
        
        if (AppUnitl.sharedManager.model.wetchat.isShow) {
           wstring = [NSString stringWithFormat:@"http://www.btkuaisou.org/word/%@.html",[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }else{
            wstring = [NSString stringWithFormat:@"http://v.baidu.com/v?word=%@",[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }


    NSURL* url = [NSURL URLWithString:wstring];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [_webView loadRequest:request];//加载
    }
    
}
#pragma mark - 初始化控件



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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppUnitl sharedManager].model.video.videoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    VideoPlayModel *model = [[AppUnitl sharedManager].model.video.videoArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", model.videoTitle];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
    [cell addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(cell);
        make.height.mas_equalTo(0.25);
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_searchBar resignFirstResponder];
    [MobClick beginLogPageView:@"进入老司机页面"];
    XiaoshuoViewController *videoVC = [[XiaoshuoViewController alloc]init];
    videoVC.model =  [[AppUnitl sharedManager].model.video.videoArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:videoVC animated:YES];
}


@end
