//
//  MineViewController.m
//  XiaoShuoTool
//
//  Created by 安风 on 2017/5/11.
//  Copyright © 2017年 TheLastCode. All rights reserved.
//

#import "MineViewController.h"
#import "ZFDownloadViewController.h"
#import "DaiLuViewController.h"
#import "NewDateCodeViewController.h"
#import "SDImageCache.h"
#import "CollectionViewController.h"
#import "DNPayAlertView.h"
#import "NSObject+ALiHUD.h"

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
        make.top.equalTo(self.view.mas_top);
    }];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"pinglun"] && [AppUnitl sharedManager].model.wetchat.isAlertShow) {
        UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:[AppUnitl sharedManager].model.wetchat.alertTitle message:[AppUnitl sharedManager].model.wetchat.alertText delegate:self   cancelButtonTitle:@"取消" otherButtonTitles:@"去评论",nil];
        [infoAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *str = [NSString stringWithFormat:
                         @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",
                         @"1239455471"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"pinglun"];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
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

        return 2;
   
    }else{
        return 1;
        
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
            
            if (indexPath.row == 0) {
                cell.textLabel.text = [AppUnitl sharedManager].model.wetchat.wetchatTitle;
            }else{
                
                if ([AppUnitl getBoolMiMa]) {
                    cell.textLabel.text = @"重置密码";
                }else{
                    
                    cell.textLabel.text = @"设置密码";
                }
                UIView *line = [[UIView alloc]init];
                line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
                [cell addSubview:line];
                
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.and.top.equalTo(cell);
                    make.height.mas_equalTo(0.25);
                }];
            }
            
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
                    
                    float tmpSize = [[SDImageCache sharedImageCache]getSize];
                    
                    NSLog(@"%f",tmpSize);
//                    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
//                    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
                    cell.textLabel.text = [NSString stringWithFormat:@"清除缓存      %.2fM",tmpSize/1024/1024];
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
            float tmpSize = [[SDImageCache sharedImageCache]getSize];
            
            NSLog(@"%f",tmpSize);
            cell.textLabel.text = [NSString stringWithFormat:@"清除缓存      %.2fM",tmpSize/1024/1024];
        }else{
  
//                cell.textLabel.text = @"赏个好评";
//                UIView *line = [[UIView alloc]init];
//                line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
//                [cell addSubview:line];
//                
//                [line mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.and.right.and.top.equalTo(cell);
//                    make.height.mas_equalTo(0.25);
//                }];
            
            if ([AppUnitl getBoolMiMa]) {
                cell.textLabel.text = @"重置密码";
            }else{
                
                cell.textLabel.text = @"设置密码";
            }
            UIView *line = [[UIView alloc]init];
            line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
            [cell addSubview:line];
            
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.and.top.equalTo(cell);
                make.height.mas_equalTo(0.25);
            }];
            
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([AppUnitl sharedManager].model.wetchat.isShow) {
        if (indexPath.section == 0) {
//            cell.textLabel.text = [AppUnitl sharedManager].model.wetchat.wetchatTitle;
            
            
            if (indexPath.row == 0) {
                DaiLuViewController *lu = [[DaiLuViewController alloc]init];
                [self.navigationController pushViewController:lu animated:YES];
            }else{
//                cell.textLabel.text = @"设置密码";
                if ([AppUnitl getBoolMiMa]) {
                    DNPayAlertView *payAlert = [[DNPayAlertView alloc]init];
                    payAlert.detail = @"密码设置";
                    payAlert.amount= @"请输入老密码";
                    payAlert.isThree = YES;
                    payAlert.twoString = @"请再一次输入密码";
                    payAlert.threeString = @"请输入新密码";
                    [payAlert show];
                    payAlert.completeHandle = ^(NSString *inputPwd) {
                        NSLog(@"密码是%@",inputPwd);
                        if ([inputPwd isEqualToString:@"两次密码不一致"]) {
                            
                            [self showErrorText:@"两次密码不一致"];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self dismissLoading];
                            });
                        }else if ([inputPwd isEqualToString:@"密码输入错误"]) {
                            
                            [self showErrorText:@"密码输入错误"];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self dismissLoading];
                            });
                        }
                        else{
                            [self showSuccessText:@"密码设置成功"];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self dismissLoading];
                            });
                            [AppUnitl addStringMiMa:inputPwd];
                            [tableView reloadData];
                        }
                    };
                }else{
                    DNPayAlertView *payAlert = [[DNPayAlertView alloc]init];
                    payAlert.detail = @"密码设置";
                    payAlert.amount= @"请输入新密码";
                    payAlert.isTwo = YES;
                    payAlert.twoString = @"请再一次输入密码";
                    [payAlert show];
                    payAlert.completeHandle = ^(NSString *inputPwd) {
                        NSLog(@"密码是%@",inputPwd);
                        if ([inputPwd isEqualToString:@"两次密码不一致"]) {
                            
                            [self showErrorText:@"两次密码不一致"];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self dismissLoading];
                            });
                        }else if ([inputPwd isEqualToString:@"密码输入错误"]) {
                            
                            [self showErrorText:@"密码输入错误"];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self dismissLoading];
                            });
                        }
                        else{
                            [AppUnitl addStringMiMa:inputPwd];
                            [tableView reloadData];
                            
                            [self showSuccessText:@"密码设置成功"];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self dismissLoading];
                            });
                        }
                    };
                
                }
                
            }
        }else{
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
//                    cell.textLabel.text = @"收藏";
                    
                    
                    CollectionViewController *vc = [[CollectionViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
//                    cell.textLabel.text = @"下载";
                    if (AppUnitl.sharedManager.isDownLoad) {
                        ZFDownloadViewController *vc = [[ZFDownloadViewController alloc]init];
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
//                        UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"提示"message:@"您的版本不是VIP版本，下载VIP版可提供下载功能，尽享免广告观看!" delegate:self   cancelButtonTitle:@"取消" otherButtonTitles:@"下载",nil];
//                        [infoAlert show];
                        
                    }
                }
            }else{
                if (indexPath.row == 0) {

                    //                cell.textLabel.text = @"清楚缓存";
                    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                        [tableView reloadData];
                    }]; 
                }else{
//                    cell.textLabel.text = @"赏个好评";
                     [self pushPinglun];
//                    NewDateCodeViewController *vc = [[NewDateCodeViewController alloc]init];
//                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
    }else{
        if (indexPath.section == 0) {
            //                cell.textLabel.text = @"清楚缓存";
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                [tableView reloadData];
            }];
        }else{
//            [self pushPinglun];
//                cell.textLabel.text = @"赏个好评";
//                NewDateCodeViewController *vc = [[NewDateCodeViewController alloc]init];
//                [self.navigationController pushViewController:vc animated:YES];
            
            if ([AppUnitl getBoolMiMa]) {
                DNPayAlertView *payAlert = [[DNPayAlertView alloc]init];
                payAlert.detail = @"密码设置";
                payAlert.amount= @"请输入老密码";
                payAlert.isThree = YES;
                payAlert.twoString = @"请再一次输入密码";
                payAlert.threeString = @"请输入新密码";
                [payAlert show];
                payAlert.completeHandle = ^(NSString *inputPwd) {
                    NSLog(@"密码是%@",inputPwd);
                    if ([inputPwd isEqualToString:@"两次密码不一致"]) {
                        
                        [self showErrorText:@"两次密码不一致"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self dismissLoading];
                        });
                    }else if ([inputPwd isEqualToString:@"密码输入错误"]) {
                        
                        [self showErrorText:@"密码输入错误"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self dismissLoading];
                        });
                    }
                    else{
                        [self showSuccessText:@"密码设置成功"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self dismissLoading];
                        });
                        [AppUnitl addStringMiMa:inputPwd];
                        [tableView reloadData];
                    }
                };
            }else{
                DNPayAlertView *payAlert = [[DNPayAlertView alloc]init];
                payAlert.detail = @"密码设置";
                payAlert.amount= @"请输入新密码";
                payAlert.isTwo = YES;
                payAlert.twoString = @"请再一次输入密码";
                [payAlert show];
                payAlert.completeHandle = ^(NSString *inputPwd) {
                    NSLog(@"密码是%@",inputPwd);
                    if ([inputPwd isEqualToString:@"两次密码不一致"]) {
                        
                        [self showErrorText:@"两次密码不一致"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self dismissLoading];
                        });
                    }else if ([inputPwd isEqualToString:@"密码输入错误"]) {
                        
                        [self showErrorText:@"密码输入错误"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self dismissLoading];
                        });
                    }
                    else{
                        [AppUnitl addStringMiMa:inputPwd];
                        [tableView reloadData];
                        
                        [self showSuccessText:@"密码设置成功"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self dismissLoading];
                        });
                    }
                };
                
            }
            
        }
    }
}

-(void)pushPinglun{
    NSString *str = [NSString stringWithFormat:
                     @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",
                     @"1239455471"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == 1) {
//        [MobClick event:@"前往微信"];
//        
//        NSString *str = @"weixin:/";
//        
//        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
//    }
//}

@end
