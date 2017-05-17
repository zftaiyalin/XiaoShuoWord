//
//  WifiViewController.m
//  XiaoShuoTool
//
//  Created by 曾富田 on 2017/5/17.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "WifiViewController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHttpConnection.h"
#import "HTTPConnection.h"

#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
//#import "wwanconnect.h//frome apple 你可能没有哦
#import <SystemConfiguration/SystemConfiguration.h>
#import "UploadViewController.h"


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface WifiViewController ()<UITableViewDelegate,UITableViewDataSource>
{
   	HTTPServer *httpServer;
    UITableView *_tableView;
    UILabel *label;
}

@end

@implementation WifiViewController
- (NSString *) localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本地资源";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"wifi.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushWifi)];
    
    self.navigationItem.rightBarButtonItem = item;
    
    // Do any additional setup after loading the view, typically from a nib.
    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Initalize our http server
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:16000];
    
    // Serve files from the standard Sites folder
//    NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
    
    
    NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] stringByDeletingLastPathComponent];
    DDLogInfo(@"Setting document root: %@", docRoot);
    
    [httpServer setDocumentRoot:docRoot];
    
    [httpServer setConnectionClass:[MyHttpConnection class]];
    
    NSError *error = nil;
    if(![httpServer start:&error])
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.hidden = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
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
    label.text = @"没有可以播放的视频\n您可以通过iTunes软件或WiFi文件传输导入视频";
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
}

-(void)pushWifi{
    UploadViewController *vc = [[UploadViewController alloc]init];
    
    
    NSString *ip = [self localWiFiIPAddress];
    NSLog(@"%@",ip);
    vc.ipString = [NSString stringWithFormat:@"http://%@:16000",ip];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getVideoArrayToPhone];
}

-(NSMutableArray *)getVideoArrayToPhone{

//    NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] stringByDeletingLastPathComponent];
//    NSString* path = [docRoot stringByAppendingPathComponent: @"/resourse"];
    NSString* path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"resourse"];
//    NSString* path = [http getUploadPath];   // 要列出来的目录
    
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator;
    
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:path];
    
    //列举目录内容，可以遍历子目录
    
    NSLog(@"用enumeratorAtPath:显示目录%@的内容：",path);
    
    while((path=[myDirectoryEnumerator nextObject])!=nil)
        
    {
        
        NSLog(@"===============%@",path);
        
        
        if ([[path pathExtension] isEqualToString:@"mp4"] || [[path pathExtension] isEqualToString:@"MP4"] || [[path pathExtension] isEqualToString:@"MPG"] || [[path pathExtension] isEqualToString:@"mpg"] || [[path pathExtension] isEqualToString:@"3GP"] || [[path pathExtension] isEqualToString:@"3gp"] || [[path pathExtension] isEqualToString:@"XVID"] || [[path pathExtension] isEqualToString:@"xvid"] || [[path pathExtension] isEqualToString:@"RM"] || [[path pathExtension] isEqualToString:@"rm"] || [[path pathExtension] isEqualToString:@"RMVB"] || [[path pathExtension] isEqualToString:@"rmvb"] || [[path pathExtension] isEqualToString:@"MKV"] || [[path pathExtension] isEqualToString:@"mkv"] || [[path pathExtension] isEqualToString:@"AVI"] || [[path pathExtension] isEqualToString:@"avi"] || [[path pathExtension] isEqualToString:@"WMV"] || [[path pathExtension] isEqualToString:@"wmv"] ) {
            
        }
        
    }
    
    return [NSMutableArray array];
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
//    VideoPlayModel *model = [[AppUnitl sharedManager].model.video.videoArray objectAtIndex:indexPath.row];
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"%@", model.videoTitle];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    UIView *line = [[UIView alloc]init];
//    line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
//    [cell addSubview:line];
//    
//    [line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.right.and.top.equalTo(cell);
//        make.height.mas_equalTo(0.25);
//    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [searchBar resignFirstResponder];
//    XiaoshuoViewController *videoVC = [[XiaoshuoViewController alloc]init];
//    videoVC.model =  [[AppUnitl sharedManager].model.video.videoArray objectAtIndex:indexPath.row];
//    [self.navigationController pushViewController:videoVC animated:YES];
}

@end
