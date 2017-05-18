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
#import "UMVideoAd.h"
@interface CollectionViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    UILabel *label;
    NSMutableArray *videoArray;
}

@end

@implementation CollectionViewController
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
    self.title = @"收藏";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"获取积分" style:UIBarButtonItemStylePlain target:self action:@selector(huoqujifen)];
    
    self.navigationItem.rightBarButtonItem = item;
    
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
    
    [self getVideoArrayToPhone];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
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
    AppLocaVideoModel *model = [videoArray objectAtIndex:indexPath.row];
    MoviePlayerViewController *movie = [[MoviePlayerViewController alloc]init];
    movie.videoURL                   = [NSURL fileURLWithPath:model.path isDirectory:YES];
    movie.titleSring = model.title;
    movie.isShowCollect = YES;
    [self.navigationController pushViewController:movie animated:NO];
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
@end
