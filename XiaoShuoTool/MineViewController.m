//
//  MineViewController.m
//  XiaoShuoTool
//
//  Created by 安风 on 2017/5/11.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "MineViewController.h"
#import "Masonry.h"
#import "UMVideoAd.h"
#import "ZFDownloadViewController.h"
#import "DaiLuViewController.h"

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#efeff5"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection=YES;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#efeff5"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(50);
    }];
    
    UMBannerView *bannerView = [UMVideoAd videoBannerPlayerFrame:CGRectMake(0, 64, self.view.frame.size.width, 50) videoBannerPlayCloseCallBackBlock:^(BOOL isLegal){
        NSLog(@"关闭banner");
        NSLog(@"close banner");
    }];
    
    [self.view addSubview:bannerView];
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
    return [AppUnitl sharedManager].model.wetchat.isShow ? 3:2;
    
    //收藏 清楚缓存 赏个好评 下载
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([AppUnitl sharedManager].model.wetchat.isShow) {
        if (section == 0) {
            return 1;
        }else{
            return 2;
        }
    }else{
         return 2;
    }
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

    
    if ([AppUnitl sharedManager].model.wetchat.isShow) {
        if (indexPath.section == 0) {
            cell.textLabel.text = [AppUnitl sharedManager].model.wetchat.wetchatTitle;
        }else{
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"收藏";
                }else{
                    cell.textLabel.text = @"下载";
                    
                    UIView *line = [[UIView alloc]init];
                    line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
                    [cell addSubview:line];
                    
                    [line mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.and.right.and.top.equalTo(cell);
                        make.height.mas_equalTo(0.25);
                    }];
                    
                }
            }else{
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"清除缓存";
                }else{
                    cell.textLabel.text = @"赏个好评";
                    UIView *line = [[UIView alloc]init];
                    line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
                    [cell addSubview:line];
                    
                    [line mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.and.right.and.top.equalTo(cell);
                        make.height.mas_equalTo(0.25);
                    }];
                }
            }
        }
    }else{
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"收藏";
            }else{
                cell.textLabel.text = @"下载";
                UIView *line = [[UIView alloc]init];
                line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
                [cell addSubview:line];
                
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.and.top.equalTo(cell);
                    make.height.mas_equalTo(0.25);
                }];
            }
        }else{
            if (indexPath.row == 1) {
                cell.textLabel.text = @"清除缓存";
            }else{
                cell.textLabel.text = @"赏个好评";
                UIView *line = [[UIView alloc]init];
                line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
                [cell addSubview:line];
                
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.and.top.equalTo(cell);
                    make.height.mas_equalTo(0.25);
                }];
            }
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([AppUnitl sharedManager].model.wetchat.isShow) {
        if (indexPath.section == 0) {
//            cell.textLabel.text = [AppUnitl sharedManager].model.wetchat.wetchatTitle;
            DaiLuViewController *lu = [[DaiLuViewController alloc]init];
            [self.navigationController pushViewController:lu animated:YES];
        }else{
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
//                    cell.textLabel.text = @"收藏";
                }else{
//                    cell.textLabel.text = @"下载";
                    ZFDownloadViewController *vc = [[ZFDownloadViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else{
                if (indexPath.row == 0) {
//                    cell.textLabel.text = @"清楚缓存";
                }else{
//                    cell.textLabel.text = @"赏个好评";
                }
            }
        }
    }else{
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
//                cell.textLabel.text = @"收藏";
            }else{
//                cell.textLabel.text = @"下载";
                ZFDownloadViewController *vc = [[ZFDownloadViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else{
            if (indexPath.row == 1) {
//                cell.textLabel.text = @"清楚缓存";
            }else{
//                cell.textLabel.text = @"赏个好评";
            }
        }
    }
}


@end
