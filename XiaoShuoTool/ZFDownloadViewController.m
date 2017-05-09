//
//  ZFDownloadViewController.m
//  XiaoShuoTool
//
//  Created by 安风 on 2017/5/6.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "ZFDownloadViewController.h"
//#import "MoviePlayerViewController.h"
#import "ZFPlayer.h"
#import "ZFDownloadingCell.h"
#import "ZFDownloadedCell.h"
#import "ZFDownloadManager.h"
#import "Masonry.h"
#import "MoviePlayerViewController.h"

#define  DownloadManager  [ZFDownloadManager sharedDownloadManager]

static NSString * const downloadingCell = @"ZFDownloadingCell";

static NSString * const dwnloadedCell = @"ZFDownloadedCell";

@interface ZFDownloadViewController ()<UITableViewDataSource,UITableViewDelegate,ZFDownloadDelegate>
@property (atomic, strong ) NSMutableArray *downloadObjectArr;
@property (strong, nonatomic) UITableView    *tableView;
@end

@implementation ZFDownloadViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    // 更新数据源
    [self initData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.allowsSelection=YES;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
        [self.tableView registerClass:[ZFDownloadingCell class] forCellReuseIdentifier:downloadingCell];
        [self.tableView registerClass:[ZFDownloadedCell class] forCellReuseIdentifier:dwnloadedCell];
        [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    
//    self.tableView.tableFooterView = [UIView new];
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -49, 0);
    DownloadManager.downloadDelegate = self;
    // NSLog(@"%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES));
}

- (void)initData {
    [DownloadManager startLoad];
    NSMutableArray *downladed = DownloadManager.finishedlist;
    NSMutableArray *downloading = DownloadManager.downinglist;
    self.downloadObjectArr = @[].mutableCopy;
    [self.downloadObjectArr addObject:downladed];
    [self.downloadObjectArr addObject:downloading];
    [self.tableView reloadData];
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
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.downloadObjectArr[section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ZFDownloadedCell *cell = [tableView dequeueReusableCellWithIdentifier:dwnloadedCell];
        ZFFileModel *fileInfo = self.downloadObjectArr[indexPath.section][indexPath.row];
        cell.fileInfo = fileInfo;
        return cell;
    } else if (indexPath.section == 1) {
        ZFDownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:downloadingCell];
        ZFHttpRequest *request = self.downloadObjectArr[indexPath.section][indexPath.row];
        if (request == nil) { return nil; }
        ZFFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
        
        __weak typeof(self) weakSelf = self;
        // 下载按钮点击时候的要刷新列表
        cell.btnClickBlock = ^{
            [weakSelf initData];
        };
        // 下载模型赋值
        cell.fileInfo = fileInfo;
        // 下载的request
        cell.request = request;
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
   
        ZFFileModel *model                 = self.downloadObjectArr[indexPath.section][indexPath.row];
        // 文件存放路径
        NSString *path                   = FILE_PATH(model.fileName);
        NSURL *videoURL                  = [NSURL fileURLWithPath:path];
        
        MoviePlayerViewController *movie = [[MoviePlayerViewController alloc]init];
        movie.videoURL                   = videoURL;
        [self.navigationController pushViewController:movie animated:NO];
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ZFFileModel *fileInfo = self.downloadObjectArr[indexPath.section][indexPath.row];
        [DownloadManager deleteFinishFile:fileInfo];
    }else if (indexPath.section == 1) {
        ZFHttpRequest *request = self.downloadObjectArr[indexPath.section][indexPath.row];
        [DownloadManager deleteRequest:request];
    }
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"下载完成",@"下载中"][section];
}

#pragma mark - ZFDownloadDelegate

// 开始下载
- (void)startDownload:(ZFHttpRequest *)request {
    NSLog(@"开始下载!");
}

// 下载中
- (void)updateCellProgress:(ZFHttpRequest *)request {
    ZFFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
}

// 下载完成
- (void)finishedDownload:(ZFHttpRequest *)request {
    [self initData];
}

// 更新下载进度
- (void)updateCellOnMainThread:(ZFFileModel *)fileInfo {
    NSArray *cellArr = [self.tableView visibleCells];
    for (id obj in cellArr) {
        if([obj isKindOfClass:[ZFDownloadingCell class]]) {
            ZFDownloadingCell *cell = (ZFDownloadingCell *)obj;
            if([cell.fileInfo.fileURL isEqualToString:fileInfo.fileURL]) {
                cell.fileInfo = fileInfo;
            }
        }
    }
}

@end
